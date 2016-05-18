function show_headers(filename)
% SHOW_HEADERS Show header info.
%
%    SHOW_HEADERS(FILENAME) shows header (MPH/SPH/DSD-array) info.
%

pf = coda_open(filename);
if strncmp(coda_product_class(pf), 'ENVISAT', 7)
  mph = coda_fetch(pf, 'MPH');
  disp('  MPH :')
  disp(mph);
  sph = coda_fetch(pf, 'SPH');
  disp('  SPH :')
  disp(sph);
  dsd = coda_fetch(pf, 'DSD');
  num_dsd = length(dsd);
  for i=1:num_dsd
    disp(sprintf('  DSD(%d) :', i));
    disp(dsd(i));
  end
else
  disp('Not an ENVISAT product file');
end
coda_close(pf);
