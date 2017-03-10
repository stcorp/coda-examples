% change this to the full path of your Aeolus L2A DBL file
filename = '/path/to/AE_OPER_ALD_U_N_2A_20071107T193753059_008688000_000578_0001.DBL';

product = coda_open(filename);

% ### Standard Correct Algorithm (SCA) at middle bins ###

if coda_fieldavailable(product, 'sca_optical_properties')
  disp('SCA optical properties at middle bins');
  latitude = coda_fetch(product, 'sca_optical_properties', -1, 'geolocation_middle_bins', -1, 'latitude');
  latitude = horzcat(latitude{:});

  longitude = coda_fetch(product, 'sca_optical_properties', -1, 'geolocation_middle_bins', -1, 'longitude');
  longitude = horzcat(longitude{:});

  altitude = coda_fetch(product, 'sca_optical_properties', -1, 'geolocation_middle_bins', -1, 'altitude');
  altitude = horzcat(altitude{:});

  extinction = coda_fetch(product, 'sca_optical_properties', -1, 'sca_optical_properties_mid_bins', -1, 'extinction');
  extinction = horzcat(extinction{:});
  disp(size(extinction));

  backscatter = coda_fetch(product, 'sca_optical_properties', -1, 'sca_optical_properties_mid_bins', -1, 'backscatter');
  backscatter = horzcat(backscatter{:});
  disp(size(backscatter));
end

% ### Standard Correct Algorithm (SCA) ###

if coda_fieldavailable(product, 'sca_optical_properties')
  disp('SCA optical properties');
  extinction = coda_fetch(product, 'sca_optical_properties', -1, 'sca_optical_properties', -1, 'extinction');
  extinction = horzcat(extinction{:});
  disp(size(extinction));

  backscatter = coda_fetch(product, 'sca_optical_properties', -1, 'sca_optical_properties', -1, 'backscatter');
  backscatter = horzcat(backscatter{:});
  disp(size(backscatter));
end


% ### Iterative Correct Algorithm (ICA) ###

if coda_fieldavailable(product, 'ica_optical_properties')
  disp('ICA optical properties')
  extinction = coda_fetch(product, 'ica_optical_properties', -1, 'ica_optical_properties', -1, 'extinction');
  extinction = horzcat(extinction{:});
  disp(size(extinction));

  backscatter = coda_fetch(product, 'ica_optical_properties', -1, 'ica_optical_properties', -1, 'backscatter');
  backscatter = horzcat(backscatter{:});
  disp(size(backscatter));
end

% ### Mie Channel Algorithm (MCA) ###

if coda_fieldavailable(product, 'mca_optical_properties')
  disp('MCA optical properties');
  extinction = coda_fetch(product, 'mca_optical_properties', -1, 'mca_optical_properties', -1, 'extinction');
  extinction = horzcat(extinction{:});
  disp(size(extinction));
end

coda_close(product);
