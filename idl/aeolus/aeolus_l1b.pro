pro aeolus_l1b
  ; change this to the full path of your Aeolus L1B DBL file
  filename = '/path/to/AE_OPER_ALD_U_N_1B_20151002T001857059_005787000_046339_0001.DBL'
  
  product = coda_open(filename)
  
  ; ### Observation profiles ###
  
  geolocation_record = coda_fetch(product, 'geolocation')
  wind_velocity_record = coda_fetch(product, 'wind_velocity')
  
  ; Mie observation wind profiles
  
  print, 'Mie observation wind profiles'
  
  for i = 0, n_elements(geolocation_record) - 1 do begin
    latitude = coda_fetch(geolocation_record[i], 'observation_geolocation/observation_mie_geolocation', -1, 'latitude_of_height_bin')
    longitude = coda_fetch(geolocation_record[i], 'observation_geolocation/observation_mie_geolocation', -1, 'longitude_of_height_bin')
    altitude = coda_fetch(geolocation_record[i], 'observation_geolocation/observation_mie_geolocation', -1, 'altitude_of_height_bin')
  endfor
  
  for i = 0, n_elements(wind_velocity_record) - 1 do begin
    wind_velocity = coda_fetch(wind_velocity_record[i], 'observation_wind_profile/mie_altitude_bin_wind_info', -1, 'wind_velocity')
  endfor
  
  ; Rayleigh observation wind profiles
  
  print, 'Rayleigh observation wind profiles'
  
  for i = 0, n_elements(geolocation_record) - 1 do begin
    latitude = coda_fetch(geolocation_record[i], 'observation_geolocation/observation_rayleigh_geolocation', -1, 'latitude_of_height_bin')
    longitude = coda_fetch(geolocation_record[i], 'observation_geolocation/observation_rayleigh_geolocation', -1, 'longitude_of_height_bin')
    altitude = coda_fetch(geolocation_record[i], 'observation_geolocation/observation_rayleigh_geolocation', -1, 'altitude_of_height_bin')
  endfor
  
  for i = 0, n_elements(wind_velocity_record) - 1 do begin
    wind_velocity = coda_fetch(wind_velocity_record[i], 'observation_wind_profile/rayleigh_altitude_bin_wind_info', -1, 'wind_velocity')
  endfor
  
  ; ### Measurement profiles ###
  
  ; Mie measurement wind profiles
  
  print, 'Mie measurement wind profiles'
  
  for i = 0, n_elements(geolocation_record) - 1 do begin
    brcgeo_record = coda_fetch(geolocation_record[i], 'measurement_geolocation')
    for j = 0, n_elements(brcgeo_record) - 1 do begin
      latitude = coda_fetch(brcgeo_record[j], 'mie_geolocation', -1, 'latitude_of_height_bin')
      longitude = coda_fetch(brcgeo_record[j], 'mie_geolocation', -1, 'longitude_of_height_bin')
      altitude = coda_fetch(brcgeo_record[j], 'mie_geolocation', -1, 'altitude_of_height_bin')
    endfor
  endfor
  
  for i = 0, n_elements(wind_velocity_record) - 1 do begin
    obswnd_record = coda_fetch(wind_velocity_record[i], 'measurement_wind_profile')
    for j = 0, n_elements(obswnd_record) - 1 do begin
      wind_velocity = coda_fetch(obswnd_record[j], 'mie_altitude_bin_wind_info', -1, 'wind_velocity')
    endfor
  endfor
  
  ; Rayleigh measurement wind profiles
  
  print, 'Rayleigh measurement wind profiles'
  
  for i = 0, n_elements(geolocation_record) - 1 do begin
    brcgeo_record = coda_fetch(geolocation_record[i], 'measurement_geolocation')
    for j = 0, n_elements(brcgeo_record) - 1 do begin
      latitude = coda_fetch(brcgeo_record[j], 'rayleigh_geolocation', -1, 'latitude_of_height_bin')
      longitude = coda_fetch(brcgeo_record[j], 'rayleigh_geolocation', -1, 'longitude_of_height_bin')
      altitude = coda_fetch(brcgeo_record[j], 'rayleigh_geolocation', -1, 'altitude_of_height_bin')
    endfor
  endfor
  
  for i = 0, n_elements(wind_velocity_record) - 1 do begin
    obswnd_record = coda_fetch(wind_velocity_record[i], 'measurement_wind_profile')
    for j = 0, n_elements(obswnd_record) - 1 do begin
      wind_velocity = coda_fetch(obswnd_record[j], 'rayleigh_altitude_bin_wind_info', -1, 'wind_velocity')
    endfor
  endfor
  
  ret = coda_close(product)
end