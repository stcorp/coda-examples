PRO mipas_level_2, directory

  DEVICE, DECOMPOSED=0, RETAIN=2
  LOADCT, 27

  f = findfile(directory + 'MIP_NL__2P*.N1')
  f = f[sort(f)]

  device, decomposed = 0

;  loadct, 27
;  map_set, /MERCATOR
;  map_continents

  lat  = [0D]
  alt  = [0D]
  val  = [0D]
  long = [0D]

  FOR i=0, n_elements(f)-1 DO BEGIN

    print, 'file #', i, ': ', f[i]

    pf  = coda_open(f[i])
    IF coda_is_error(pf) THEN BEGIN
      print, 'Error while opening the product: ', pf.message
    ENDIF ELSE BEGIN

      scans = coda_fetch(pf, 'scan_information_mds')

      FOR z=0, n_elements(scans)-1 DO BEGIN

        talt = coda_fetch(scans[z], 'tangent_altitude_los')
        geo_lat = coda_fetch(scans[z], 'geolocation_los_tangent', -1, 'latitude')
        geo_long = coda_fetch(scans[z], 'geolocation_los_tangent', -1, 'longitude')

        vmr  = coda_fetch(scans[z], 'retrieval_vmr', 4, 'vmr')
        lat  = [lat, geo_lat]
        long = [lat, geo_long]
        alt  = [alt, talt]
        val  = [val, alog10(vmr)]

    ENDFOR

    ; close the product file.
    dummy = coda_close(pf)

    ENDELSE

  ENDFOR

  plot, [0],[0], xrange=[-90,90], yrange=[0,80], $
    xtitle='latitude [deg]', ytitle='tangent height [km]', $
    /nodata

  plots, lat, alt, color=BYTSCL(val, MIN=-4, MAX=5), psym=3

END
