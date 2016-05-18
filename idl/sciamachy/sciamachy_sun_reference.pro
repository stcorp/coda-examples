; This is an example for SCI_NL__1P and SCI_SU1_AX products.

PRO sciamachy_sun_reference, filename

  device, decomposed = 0, retain=2
  loadct, 27
  window, xsize=800, ysize=600

  pf = coda_open(filename)
  IF coda_is_error(pf) THEN BEGIN
    print, 'Error while opening the product: ', pf.message
    RETURN
  ENDIF

  sun_reference = coda_fetch(pf, 'sun_reference')

  FOR i = 0, n_elements(sun_reference)-1 do begin

    lambda = coda_fetch(sun_reference[i], 'wvlen_sun_meas')

    ; value '999' signifies invalid data.
    IF lambda[0,0] NE 999 THEN BEGIN

      spectrum = coda_fetch(sun_reference[i], 'mean_ref_spec')
  
      tvec = [200,300,400,600,800,1000,1200,1400,1600,2000,2400]

      plot, lambda[0,*], spectrum[0,*], /xlog, /ylog, yrange=[1e10,1e18], xstyle=1, /nodata, $
        title  = STRING(format='(%"GADS sun reference spectrum (GADS #%d)")', i+1),         $
        xticks = n_elements(tvec)-1, xtickv=tvec, $
        xtitle = 'wavelength [nm]', $
        ytitle = 'response [ photons/m!E2!N !M. nm !M.s ]'

      FOR i=0,7 DO BEGIN
        oplot, lambda[i,*], spectrum[i,*], color= (i MOD 4)*40+10
      ENDFOR

      wait, 2

    ENDIF

  ENDFOR

  dummy = coda_close(pf)

END
