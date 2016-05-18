PRO gomos_level_2, filename

  ; open the product file. If an error occurred, report it.
  pf  = coda_open(filename)
  IF coda_is_error(pf) THEN BEGIN
    print, 'Error while opening the product: ', pf.message
    RETURN
  ENDIF

  ; fetch the two data-sets needed. These will be arrays of
  ; the coda_DATAHANDLE type.
  geo     = coda_fetch(pf, 'nl_geolocation')
  species = coda_fetch(pf, 'nl_local_species_density')

  ; get number of elements in both the NL_GEOLOCATION and
  ; NL_LOCAL_SPECIES_DENSITY datasets.
  n_geo = n_elements(geo)

  ; allocate double arrays to hold the tangent-altitude and O3 values.
  tangent_alt = DBLARR(n_geo)
  o3          = DBLARR(n_geo)

  ; traverse all measurement records; get tangent altitudes and
  ; O3 values for each point.
  FOR i=0,n_geo-1 DO BEGIN
    tangent_alt[i] = coda_fetch(geo[i], 'tangent_alt')
    o3 [i]         = coda_fetch(species[i], 'o3')
  ENDFOR
  ; plot height (converted to km) vs. O3.
  plot , o3, tangent_alt/1000.0, $
    title = 'GOMOS Level-2: Ozone Profile' + filename,          $
    xtitle = 'Local O!I3!N Density at tangent height [ cm!E-3!N ]', $
    yrange=[0,75], ystyle=1, ytitle='height [ km ]', color=255

  ; close the product file.
  dummy = coda_close(pf)

END
