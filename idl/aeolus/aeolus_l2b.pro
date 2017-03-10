pro aeolus_l2b
  ; change this to the full path of your Aeolus L2B DBL file
  filename = '/path/to/AE_OPER_ALD_U_N_2B_20071107T193753_20071107T220253_0001.DBL'

  product = coda_open(filename);
  
  ; The L2B product stores all valid profile points (which are called 'results') as one big consecutive array
  ; in the datasets mie_hloswind and rayleigh_hloswind.
  ; The associated geolocation for those point results are stored in mie_geolocation and rayleigh_geolocation.
  
  ; The specification of which points belong together in which profile is kept in the mie_profile and rayleigh_profile
  ; datasets. These datasets contain indices into the mie_hloswind and rayleigh hloswind datasets to specify which point
  ; belongs at which level in a profile.
  
  ; ### Mie horizontal line of sight wind profile points ###
  
  print, 'Individual Mie HLOS wind points'
  
  latitude = coda_fetch(product, 'mie_geolocation', -1, 'windresult_geolocation/latitude_cog')
  longitude = coda_fetch(product, 'mie_geolocation', -1, 'windresult_geolocation/longitude_cog')
  altitude = coda_fetch(product, 'mie_geolocation', -1, 'windresult_geolocation/altitude_vcog')
  mie_wind_velocity = coda_fetch(product, 'mie_hloswind', -1, 'windresult/mie_wind_velocity')
  help, mie_wind_velocity
  
  ; ### Rayleigh observation wind profiles points ###
  
  print, 'Individual Rayleight HLOS wind points'

  latitude = coda_fetch(product, 'rayleigh_geolocation', -1, 'windresult_geolocation/latitude_cog')
  longitude = coda_fetch(product, 'rayleigh_geolocation', -1, 'windresult_geolocation/longitude_cog')
  altitude = coda_fetch(product, 'rayleigh_geolocation', -1, 'windresult_geolocation/altitude_vcog')
  rayleigh_wind_velocity = coda_fetch(product, 'rayleigh_hloswind', -1, 'windresult/rayleigh_wind_velocity')
  help, rayleigh_wind_velocity

  ; ### Mie profile definition
  
  print, 'Mie HLOS wind profiles'
  
  mie_profile_record = coda_fetch(product, 'mie_profile', -1, 'l2b_wind_profiles')
  for i = 0, n_elements(mie_profile_record) - 1 do begin
    result_id = coda_fetch(mie_profile_record[i], 'wind_result_id_number')
    print, mie_wind_velocity[result_id[where(result_id NE 0)] - 1]
  endfor
  
  ; ### Rayleigh profile definition
  
  print, 'Rayleigh HLOS wind profiles'
  
  rayleigh_profile_record = coda_fetch(product, 'rayleigh_profile', -1, 'l2b_wind_profiles')
  for i = 0, n_elements(rayleigh_profile_record) - 1 do begin
    result_id = coda_fetch(rayleigh_profile_record[i], 'wind_result_id_number')
    print, rayleigh_wind_velocity[result_id[where(result_id NE 0)] - 1]
  endfor
  
  ret = coda_close(product)
end
