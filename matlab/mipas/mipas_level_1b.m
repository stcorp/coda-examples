function mipas_level_1b(filename)
% MIPAS_LEVEL_1B Show readouts of band A & B for MIPAS level 1b.
%
%    MIPAS_LEVEL_1B(FILENAME) shows readouts of band A & B for a
%       'MIP_NL__1P' product file.
%

% Open the product file.
pf = coda_open(filename);

if ~strcmp('MIP_NL__1P', coda_product_type(pf))
  error('coda:examples:mipas_level_1b', 'Not a MIP_NL__1P file');
end

% Get the number of MDS records
num_mds = coda_size(pf, 'mipas_level_1b_mds');

% Read all measurement records.
for i=1:num_mds
  band_a = coda_fetch(pf, 'mipas_level_1b_mds', i, 'band_a');
  band_b = coda_fetch(pf, 'mipas_level_1b_mds', i, 'band_b');

  % concatenate bands
  plot_bands = [band_a; band_b];

  % plot the data
  semilogy(plot_bands);
  title(sprintf('MIPAS Level-1b MDSR #%d', i));
  xlabel('readout number (bands A and B shown)');
  ylabel('log^{10}(radiance) [ W/(cm^2 x sr x cm^{-1}) ]');
  range = axis;
  range(3:4) = [1e-10 1e-4];
  axis(range);

  pause(0.01);

end

coda_close(pf);
