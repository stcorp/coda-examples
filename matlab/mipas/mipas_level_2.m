function mipas_level_2(filename)
% MIPAS_LEVEL_2 Show MIPAS level 2 data.
%
%    MIPAS_LEVEL_2(FILENAME) shows O3 profiles from a MIPAS
%    level 2 product file.
%

lat = [];
lon = [];
alt = [];
val = [];

% open product file
pf = coda_open(filename);

n_scans = double(coda_size(pf, 'scan_information_mds'));

species_index = 0;
index = 1;
species = coda_fetch(pf, 'sph', 'order_of_species');
while length(species) > 0
  [s species] = strtok(species,',');
  if strcmp(s,'O3')
    species_index = index;
  end
  index = index + 1;
end
if species_index==0
  disp('WARNING: Could not find O3 data. Using first species instead.');
  species_index = 1
end

alt = coda_fetch(pf, 'scan_information_mds', -1, 'tangent_altitude_los');
geo = coda_fetch(pf, 'scan_information_mds', -1, 'geolocation_los_tangent');
val = coda_fetch(pf, 'scan_information_mds', -1, 'retrieval_vmr', species_index, 'vmr');

% convert the cellarray of arrays to single 1D arrays
alt = vertcat(alt{:});
geo = vertcat(geo{:});
val = vertcat(val{:});

% close the product file.
coda_close(pf);

% remove al NaN values
index = find(isfinite(val));
alt = alt(index);
geo = geo(index);
val = val(index);

scatter3([geo.longitude], [geo.latitude], alt, 4, log10(val));
xlabel('longitude [ deg ]');
ylabel('latitude [ deg ]');
zlabel('tangent height [ km ]');
title('MIPAS Level-2');
axis([-180 180 -90 90 0 80]);
caxis([-4 5]);
colorbar('horz');
