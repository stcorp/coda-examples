% change this to the full path of your Aeolus L1B DBL file
filename = '/path/to/AE_OPER_ALD_U_N_1B_20151002T001857059_005787000_046339_0001.DBL';

product = coda_open(filename);

% ### Observation profiles ###

% Observation profiles provide a single profile per BRC.
% Reading all values will therefore return 'a cell array of arrays' (we will get an array for each '-1' in the coda.fetch()).
% The cell array is the list of BRCs, and the second array the list of points in the profile.
% This array of arrays can be turned into a single 2D array with dimensions [num_brc, num_vertical] by using 'horzcat'.

% Mie observation wind profiles

disp('Mie observation wind profiles');

latitude = coda_fetch(product, 'geolocation', -1, 'observation_geolocation/observation_mie_geolocation', -1, 'latitude_of_height_bin');
latitude = horzcat(latitude{:});

longitude = coda_fetch(product, 'geolocation', -1, 'observation_geolocation/observation_mie_geolocation', -1, 'longitude_of_height_bin');
longitude = horzcat(longitude{:});

altitude = coda_fetch(product, 'geolocation', -1, 'observation_geolocation/observation_mie_geolocation', -1, 'altitude_of_height_bin');
altitude = horzcat(altitude{:});

wind_velocity = coda_fetch(product, 'wind_velocity', -1, 'observation_wind_profile/mie_altitude_bin_wind_info', -1, 'wind_velocity');
wind_velocity = horzcat(wind_velocity{:});
disp(size(wind_velocity));

% Rayleigh observation wind profiles

disp('Rayleigh observation wind profiles')

latitude = coda_fetch(product, 'geolocation', -1, 'observation_geolocation/observation_rayleigh_geolocation', -1, 'latitude_of_height_bin');
latitude = horzcat(latitude{:});

longitude = coda_fetch(product, 'geolocation', -1, 'observation_geolocation/observation_rayleigh_geolocation', -1, 'longitude_of_height_bin');
longitude = horzcat(longitude{:});

altitude = coda_fetch(product, 'geolocation', -1, 'observation_geolocation/observation_rayleigh_geolocation', -1, 'altitude_of_height_bin');
altitude = horzcat(altitude{:});

wind_velocity = coda_fetch(product, 'wind_velocity', -1, 'observation_wind_profile/rayleigh_altitude_bin_wind_info', -1, 'wind_velocity');
wind_velocity = horzcat(wind_velocity{:});
disp(size(wind_velocity));

% ### Measurement profiles ###

% The measurement profiles provide the individual measured profiles per BRC
% This will thus provide 'a cell array of cell arrays of arrays'.
% The first array is the list of BRCs, the second array the list of measurements per BRC,
% and the final array the list of points in the profile.
% This array of arrays of arrays can be turned into a single 2D array with dimensions
% [num_brc * num_meas, num_vertical] by flattening the BRC and Measurement dimensions using 'vertcat'
% and turning the array of profile arrays into a single 2D numpy array using 'horzcat'.

% Mie measurement wind profiles

disp('Mie measurement wind profiles');

latitude = coda_fetch(product, 'geolocation', -1, 'measurement_geolocation', -1, 'mie_geolocation', -1, 'latitude_of_height_bin');
latitude = vertcat(latitude{:});
latitude = horzcat(latitude{:});

longitude = coda_fetch(product, 'geolocation', -1, 'measurement_geolocation', -1, 'mie_geolocation', -1, 'longitude_of_height_bin');
longitude = vertcat(longitude{:});
longitude = horzcat(longitude{:});

altitude = coda_fetch(product, 'geolocation', -1, 'measurement_geolocation', -1, 'mie_geolocation', -1, 'altitude_of_height_bin');
altitude = vertcat(altitude{:});
altitude = horzcat(altitude{:});

wind_velocity = coda_fetch(product, 'wind_velocity', -1, 'measurement_wind_profile', -1, 'mie_altitude_bin_wind_info', -1, 'wind_velocity');
wind_velocity = vertcat(wind_velocity{:});
wind_velocity = horzcat(wind_velocity{:});
disp(size(wind_velocity));

% Rayleigh measurement wind profiles

disp('Rayleigh measurement wind profiles')

latitude = coda_fetch(product, 'geolocation', -1, 'measurement_geolocation', -1, 'rayleigh_geolocation', -1, 'latitude_of_height_bin');
latitude = vertcat(latitude{:});
latitude = horzcat(latitude{:});

longitude = coda_fetch(product, 'geolocation', -1, 'measurement_geolocation', -1, 'rayleigh_geolocation', -1, 'longitude_of_height_bin');
longitude = vertcat(longitude{:});
longitude = horzcat(longitude{:});

altitude = coda_fetch(product, 'geolocation', -1, 'measurement_geolocation', -1, 'rayleigh_geolocation', -1, 'altitude_of_height_bin');
altitude = vertcat(altitude{:});
altitude = horzcat(altitude{:});

wind_velocity = coda_fetch(product, 'wind_velocity', -1, 'measurement_wind_profile', -1, 'rayleigh_altitude_bin_wind_info', -1, 'wind_velocity');
wind_velocity = vertcat(wind_velocity{:});
wind_velocity = horzcat(wind_velocity{:});
disp(size(wind_velocity));

coda_close(product);
