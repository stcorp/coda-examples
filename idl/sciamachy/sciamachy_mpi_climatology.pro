; This is an example for SCI_PR2_AX products.

PRO sciamachy_mpi_climatology, filename

  ; open the product file. If an error occurred, report it.
  pf = coda_open(filename)
  IF coda_is_error(pf) THEN BEGIN
    print, 'Error while opening the product: ', pf.message
    RETURN
  ENDIF

  ; read the first (and only) MPI climatology GADS record.
  mpi = coda_fetch(pf, 'mpi_climatology', 0)

  ; close the product file.
  dummy = coda_close(pf)

  ; show MPI climatology
  FOR i=0,n_elements(mpi.ref_lat)-1 DO BEGIN

    shade_surf, bytscl(reform(mpi.temp_prof[i,*,*])),                $
      mpi.cum_day_pt_prof, mpi.atm_lay_alt, charsize = 2,            $
      xstyle = 1, xrange = [0,365]  , xtitle   = 'year-time [days]', $
      ystyle = 1, yrange = [0,70]   , ytitle   = 'altitude [km]'   , $
                                      ztitle   = 'temperature [K]' , $
      title = "latitude: " + STRING(mpi.ref_lat[i])

    wait, 1

  ENDFOR

END
