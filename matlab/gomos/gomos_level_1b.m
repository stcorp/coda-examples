function gomos_level_1b(filename)
% GOMOS_LEVEL_1B Show GOMOS Level-1b data.
%
%    GOMOS_LEVEL_1B(FILENAME) shows transmission data from a 
%      gomos GOM_TRA_1P product file.
%

pf = coda_open(filename);

if ~strcmp('GOM_TRA_1P', coda_product_type(pf))
  error('coda:examples:gomos_level_1b', 'Not a GOM_TRA_1P file');
end

starname   = coda_fetch(pf, 'sph', 'star');
lambda_map = coda_fetch(pf, 'tra_nom_wav_assignment', 1, 'nom_wl');

% determine start-time. This is useful for providing display of
% time since start-of-occultation
Tstart = coda_fetch(pf, 'tra_transmission', 1, 'dsr_time');

num_trans_mds = coda_size(pf, 'tra_transmission');

% fetch time and spectrum contained in this MDSR
T        = coda_fetch(pf, 'tra_transmission', -1, 'dsr_time');
spectrum = coda_fetch(pf, 'tra_transmission', -1, 'trans_spectra');

for i=1:num_trans_mds
  % plot the spectrum and some annotation information
  plot(lambda_map, spectrum{i});
  range = axis;
  range(3:4) = [-0.2 1.2];
  axis(range);
  xlabel('wavelength [ nm ]');
  ylabel('transmission [ - ]');
  title(sprintf('star : %s time: %s (%6.3f s)', starname, coda_time_to_string(T(i)), (T(i)-Tstart)));

  pause(0.01);

end

coda_close(pf);
