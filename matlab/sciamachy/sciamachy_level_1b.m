function sciamachy_level_1b(filename)
% SCIAMACHY_LEVEL_1B Show SCIAMACHY Level-1b data.
%
%    SCIAMACHY_LEVEL_1B(FILENAME) performs a read of all clusters of a
%      sciamachy Level-1b file.
%

pf = coda_open(filename);

if ~strcmp('SCI_NL__1P', coda_product_type(pf))
  error('coda:examples:sciamachy_level_1b', 'Not a SCI_NL__1P file');
end

% state names for all mds_types
state_name = {'no measurement' 'nadir' 'limb' 'occultation' 'monitoring'};
% MDS record counters for nadir, limb, occultation and monitoring
rec_mds = [0 0 0 0];

lambda = coda_fetch(pf, 'spectral_base', 1, 'wvlen_det_pix');
fpn    = coda_fetch(pf, 'leakage_constant', 1, 'fpn_const' );
leak   = coda_fetch(pf, 'leakage_constant', 1, 'leak_const');
badpx  = coda_fetch(pf, 'ppg_etalon', 1, 'bad_pix_mask');

ads_states = coda_fetch(pf, 'states');

n_elements = length(ads_states);

for stateNr = 1:n_elements,
  tic;

  mds_type    = ads_states(stateNr).mds_type;
  num_clus    = ads_states(stateNr).num_clus;
  clus_config = ads_states(stateNr).clus_config;
  num_dsr     = ads_states(stateNr).num_dsr;

  disp(sprintf('Processing state %i of %i', stateNr, n_elements));
  disp(sprintf('  mds_type..: %i (%s)', mds_type, state_name{mds_type+1}));
  disp(sprintf('  num_clus..: %i', num_clus));
  disp(sprintf('  num_dsr...: %i', num_dsr));

  for dsrNr = 1:num_dsr,

    rec_mds(mds_type) = rec_mds(mds_type) + 1;
    recno = rec_mds(mds_type);
    clus_dat = coda_fetch(pf, state_name{mds_type+1}, recno, 'clus_dat');
    dsr_time = coda_fetch(pf, state_name{mds_type+1}, recno, 'dsr_time');
    time_str = coda_time_to_string(dsr_time);

    pixel_array = zeros(8, 1024);

    for cluster = 1:num_clus,
      clus_config = ads_states(stateNr).clus_config(cluster);

      coadd_factor   = clus_config.coadd_factor;
      pet            = clus_config.pet;
      it_as_stated   = clus_config.intgr_time;
      num_readouts   = clus_config.num_readouts;
      cluster_length = clus_config.clus_len;

      it = coadd_factor * pet;

      if it_as_stated ~= it
        disp('WARNING: integration time stated is not equal to coadd_factor*pet!');
      end

      %disp(sprintf('>  cluster_id.......: %i', clus_config.cluster_id));
      %disp(sprintf('   chan_num.........: %i', clus_config.chan_num));
      %disp(sprintf('   start_pix........: %i', clus_config.start_pix));
      %disp(sprintf('   clus_len.........: %i', clus_config.clus_len));
      %disp(sprintf('   PET..............: %f', clus_config.pet));
      %disp(sprintf('   intgr_time.......: %f', clus_config.intgr_time)/16);
      %disp(sprintf('   coadd_factor.....: %i', clus_config.coadd_factor));
      %disp(sprintf('   num_readouts.....: %i', clus_config.num_readouts));
      %disp(sprintf('   clus_data_type...: %i', clus_config.clus_data_type));

      switch clus_config.clus_data_type
        case 1,
          readouts = clus_dat(cluster).sig;
        case 2,
          readouts = clus_dat(cluster).sigc;
      end

      chan_nr  = clus_config.chan_num;
      pixel_nr = clus_config.start_pix + 1;
      last_pixel_nr = clus_config.start_pix + cluster_length;

      pixels = reshape([readouts.signal], num_readouts, cluster_length);
      pixels = sum(pixels, 1) / num_readouts;
      % calibrate pixels for leakage current and fixed pattern noise
      pixels = pixels / it - fpn(chan_nr, pixel_nr:last_pixel_nr)/pet - leak(chan_nr, pixel_nr:last_pixel_nr);
      pixel_array(chan_nr, pixel_nr:last_pixel_nr) = pixels;
    end

    % apply bad pixel mask
    pixel_array(badpx==1) = NaN;

    semilogy(lambda(1,:),pixel_array(1,:),'b');
    axis([200 2400 1e-2 1e8]);
    xlabel('wavelength [ nm ]');
    ylabel('readout [ BU/s ]');
    title(sprintf('state #%d (%s, DSR#%d): %s', stateNr, state_name{mds_type+1}, recno, time_str));
    hold on;
    semilogy(lambda(2,:),pixel_array(2,:),'g');
    semilogy(lambda(3,:),pixel_array(3,:),'r');
    semilogy(lambda(4,:),pixel_array(4,:),'m');
    semilogy(lambda(5,:),pixel_array(5,:),'b');
    semilogy(lambda(6,:),pixel_array(6,:),'g');
    semilogy(lambda(7,:),pixel_array(7,:),'r');
    semilogy(lambda(8,:),pixel_array(8,:),'m');
    hold off;

    pause(0.01);

  end

  disp(sprintf('Calculation time %g', toc));
end

coda_close(pf);
