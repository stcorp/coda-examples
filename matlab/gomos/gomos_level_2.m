function gomos_level_2(filename)
% GOMOS_LEVEL_2 Show O3 profiles from a GOMOS Level 2 product.
%
%    GOMOS_LEVEL_2(FILENAME) shows O3 profiles from a 'GOM_NL__2P'
%      product file.
%

% Open the product file.
pf = coda_open(filename);

if ~strcmp('GOM_NL__2P', coda_product_type(pf))
  error('coda:examples:gomos_level_2', 'Not a GOM_NL__2P file');
end

% Read all measurement records; get tangent altitudes and O3 values
% for each point.
tangent_alt = coda_fetch(pf, 'nl_geolocation', -1, 'tangent_alt');
o3 = coda_fetch(pf, 'nl_local_species_density', -1, 'o3');

% convert altitude to km.
tangent_alt = tangent_alt/1000;

% plot height (converted to km) vs. O3.
plot(o3, tangent_alt);
title('GOMOS Level-2: Ozone profile');
xlabel('Local O_3 density at tangent height [ cm^{-3} ]');
ylabel('height [ km ]');
range = axis;
range(3:4) = [0 75];
axis(range);

coda_close(pf);
