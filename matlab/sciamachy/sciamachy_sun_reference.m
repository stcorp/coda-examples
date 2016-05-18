function sciamachy_sun_reference(filename)
% SCIAMACHY_SUN_REFERENCE Show Sun Reference Spectra for SCIAMACHY Level 1.
%
%    SCIAMACHY_SUN_REFERENCE(FILENAME) shows Sun Reference Spectra from
%      SCI_NL__1P SUN_REFERENCE dataset.
%

pf = coda_open(filename);

if ~strcmp('SCI_NL__1P', coda_product_type(pf))
  error('coda:examples:sciamachy_sun_reference', 'Not a SCI_NL__1P file');
end

num_sun_reference = coda_size(pf, 'sun_reference');

for i=1:num_sun_reference
  lambda = coda_fetch(pf, 'sun_reference', i, 'wvlen_sun_meas');

  % value '999' signifies invalid data.
  if lambda(1)~=999
    figure;
    spectrum = coda_fetch(pf, 'sun_reference', i, 'mean_ref_spec');
    semilogy(lambda(1,:), spectrum(1,:), 'b');
    axis([200 2400 1e10 1e15]);
    xlabel('wavelength [ nm ]');
    ylabel('response [ photons/m^2 x nm x s ]');
    title(sprintf('GADS sun reference spectrum (GADS %d)', i));
    hold on;
    semilogy(lambda(2,:), spectrum(2,:), 'g');
    semilogy(lambda(3,:), spectrum(3,:), 'r');
    semilogy(lambda(4,:), spectrum(4,:), 'm');
    semilogy(lambda(5,:), spectrum(5,:), 'b');
    semilogy(lambda(6,:), spectrum(6,:), 'g');
    semilogy(lambda(7,:), spectrum(7,:), 'r');
    semilogy(lambda(8,:), spectrum(8,:), 'm');
    hold off;
  end

end

coda_close(pf);
