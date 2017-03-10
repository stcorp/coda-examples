pro aeolus_l2a
  ; change this to the full path of your Aeolus L2A DBL file
  filename = '/path/to/AE_OPER_ALD_U_N_2A_20071107T193753059_008688000_000578_0001.DBL';
  
  product = coda_open(filename);
  
  ; ### Standard Correct Algorithm (SCA) at middle bins ###
  
  if coda_fieldavailable(product, 'sca_optical_properties') then begin
    print, 'SCA optical properties at middle bins'
    scarecord = coda_fetch(product, 'sca_optical_properties')
    for i = 0, n_elements(scarecord) - 1 do begin
      latitude = coda_fetch(scarecord[i], 'geolocation_middle_bins', -1, 'latitude')
      longitude = coda_fetch(scarecord[i], 'geolocation_middle_bins', -1, 'longitude')
      altitude = coda_fetch(scarecord[i], 'geolocation_middle_bins', -1, 'altitude')
      extinction = coda_fetch(scarecord[i], 'sca_optical_properties_mid_bins', -1, 'extinction')
      backscatter = coda_fetch(scarecord[i], 'sca_optical_properties_mid_bins', -1, 'backscatter')
    endfor
  endif
  
  ; ### Standard Correct Algorithm (SCA) ###
  
  if coda_fieldavailable(product, 'sca_optical_properties') then begin
    print, 'SCA optical properties'
    scarecord = coda_fetch(product, 'sca_optical_properties')
    for i = 0, n_elements(scarecord) - 1 do begin
      extinction = coda_fetch(scarecord[i], 'sca_optical_properties', -1, 'extinction')
      backscatter = coda_fetch(scarecord[i], 'sca_optical_properties', -1, 'backscatter')
    endfor
  end
  
  
  ; ### Iterative Correct Algorithm (ICA) ###
  
  if coda_fieldavailable(product, 'ica_optical_properties') then begin
    print, 'ICA optical properties'
    icarecord = coda_fetch(product, 'ica_optical_properties')
    for i = 0, n_elements(icarecord) - 1 do begin
      extinction = coda_fetch(icarecord[i], 'ica_optical_properties', -1, 'extinction')
      backscatter = coda_fetch(icarecord[i], 'ica_optical_properties', -1, 'backscatter')
    endfor
  end
  
  ; ### Mie Channel Algorithm (MCA) ###
  
  if coda_fieldavailable(product, 'mca_optical_properties') then begin
    print, 'MCA optical properties'
    mcarecord = coda_fetch(product, 'mca_optical_properties')
    for i = 0, n_elements(mcarecord) - 1 do begin
      extinction = coda_fetch(mcarecord[i], 'mca_optical_properties', -1, 'extinction')
    endfor
  end
  
  ret = coda_close(product)
end