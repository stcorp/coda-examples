PRO sciamachy_level_2, directory

  ; note that this will fail miserably if there are *TOO MANY*
  ; files in a given directory matching the pattern. It seems like
  ; IDL does something like popen("ls <pattern>", "r"). Sigh.

  f = findfile(directory + 'SCI_NL__2P*.N1')
  f = f[sort(f)]

  device, decomposed = 0
  window, xsize=1400, ysize=1000

  netherlands = [50,-5,60,15]
  europe      = [40,-20,70,40]
  world       = [-90,-180,90,180]

  loadct, 27
  tvlct, [100],[100],[100], 255
  map_set, /ROBINSON, /HIRES, LIMIT=world
  map_continents, /HIRES, /FILL_CONTINENTS, color=255
  map_grid, color = 20

  clat  = DBLARR(4)
  clong = DBLARR(4)

  FOR i=0,n_elements(f)-1 DO BEGIN

    print, 'file #', i, ': ', f[i]

    pf  = coda_open(f[i])
    IF coda_is_error(pf) THEN BEGIN
      print, 'Error while opening the product: ', pf.message
      RETURN
    ENDIF

    geo = coda_fetch(pf, 'geolocation')
    o3  = coda_fetch(pf, 'doas_1_o3')

    ; if the o3 array contains at least one true DSR:
    IF NOT coda_is_error(o3) THEN BEGIN

      ; get the 'dsr_time' value of each of the GEOLOCATION DSRs
      geo_time = DBLARR(n_elements(geo))
      FOR j=0,n_elements(geo)-1 DO BEGIN
        geo_time[j] = coda_fetch(geo[j], 'dsr_time')
      END

      ; traverse the O3 records
      FOR j=0,n_elements(o3)-1 DO BEGIN

        vcd    = coda_fetch(o3[j], 'vcd')
        it_vcd = coda_fetch(o3[j], 'integr_time')

        IF NOT FINITE(vcd) THEN vcd=-1 ; handle NaN
        IF vcd GT 0 THEN BEGIN
          t = coda_fetch(o3[j], 'dsr_time')
          geo_index = (WHERE(geo_time EQ t))[0]

          color_value = ((alog10(vcd) > 18.5 < 20)-18.5)*255/1.5
          it_geo   = coda_fetch(geo[geo_index], 'integr_time')

          n_ground = it_vcd / it_geo

          FOR gp=0, n_ground-1 DO BEGIN

            corners  = coda_fetch(geo[geo_index+gp], 'cor_coor_nad')
            corners_lat  = coda_fetch(geo[geo_index+gp], 'cor_coor_nad', -1, 'latitude')
            corners_long  = coda_fetch(geo[geo_index+gp], 'cor_coor_nad', -1, 'longitude')
          
            clat[0]  = corners_lat[0] & clong[0] = corners_long[0]
            clat[1]  = corners_lat[1] & clong[1] = corners_long[1]
            clat[2]  = corners_lat[3] & clong[2] = corners_long[3]
            clat[3]  = corners_lat[2] & clong[3] = corners_long[2]

            polyfill, clong, clat, color=color_value

          ENDFOR
        ENDIF

      ENDFOR

    ENDIF

    ; close the product file.
    dummy = coda_close(pf)

  ENDFOR
END
