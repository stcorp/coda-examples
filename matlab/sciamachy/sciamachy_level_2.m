function sciamachy_level_2(directory)
% SCIAMACHY_LEVEL_2 Show SCIAMACHY Level-2 data.
%
%    SCIAMACHY_LEVEL_2(directory) shows O3 vcd data from one or more
%    'SCI_NL__2P' product files.
%

netherlands = [  -5   15   50   60];
europe      = [ -20   40   40   70];
world       = [-180  180  -90   90];

frame = world;

% find all files in the specified directory.
files = dir(strcat(directory,'/SCI_NL__2P*.N1'));

num_files = length(files);

if num_files == 0 
  disp('WARNING: no files found!');
end

figure;

for f=1:num_files

   lat  = [];
   long = [];
   val  = [];

   disp(sprintf('file #%04d : %s', f, files(f).name));

   % open product file
   pf = coda_open(strcat(directory,'/',files(f).name));

   % check if the profile we want is available in the product
   if (strmatch('doas_0_o3', coda_fieldnames(pf)) > 0)
     geo_time = coda_fetch(pf, 'geolocation', -1, 'dsr_time');
     geo_integr_time = coda_fetch(pf, 'geolocation', -1, 'integr_time');
     geo_loc  = coda_fetch(pf, 'geolocation', -1, 'cen_coor_nad');
     time = coda_fetch(pf, 'doas_0_o3', -1, 'dsr_time');
     vcd  = coda_fetch(pf, 'doas_0_o3', -1, 'vcd');
     integr_time = coda_fetch(pf, 'doas_0_o3', -1, 'integr_time');

     % remove all invalid measurements
     index = find(isfinite(vcd) & vcd > 0);
     time = time(index);
     vcd = vcd(index);
     integr_time = integr_time(index);

     % we just plot each geolocation pixel that corresponds with
     % this measurement.
     num_elements = length(vcd);
     geo_first = zeros(num_elements,1);
     for i=1:num_elements
       % Set geo_first to the first index in geo_time where
       % geo_time[index] equals t
       first = find(geo_time == time(i));
       geo_first(i) = first(1);
     end
     % Find out how many ground pixels correspond with this vcd
     num_gp = integr_time ./ geo_integr_time(geo_first);
     geo_last = geo_first + num_gp - 1;
     tot_num_gp = sum(num_gp);
     lat = zeros(tot_num_gp,1);
     long = zeros(tot_num_gp,1);
     val = zeros(tot_num_gp,1);

     offset = 1;
     for i=1:num_elements
       geo = [geo_loc{geo_first(i):geo_last(i)}];
       % add latitude, longitude, and vcd to list
       lat(offset:offset+num_gp(i)-1) = [geo.latitude];
       long(offset:offset+num_gp(i)-1) = [geo.longitude];
       val(offset:offset+num_gp(i)-1)  = deal(log10(vcd(i)));
       offset = offset + num_gp(i);
     end

     hold on;
     scatter(long, lat, 1, val);
     xlabel('longitude [ deg ]');
     ylabel('latitude [ deg ]');
     title('Sciamachy Level-2 Ozone');
     axis(frame);
     caxis([18.5 20]);
     colorbar('horz');
     hold off;

     pause(0.01);
   else
     disp('Retrieval not available');
   end

   coda_close(pf);
end
