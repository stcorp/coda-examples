PRO show_headers, filename

  ; open the product file. If an error occurred, report it.
  pf  = coda_open(filename)
  IF coda_is_error(pf) THEN BEGIN
    print, 'Error while opening the product: ', pf.message
    RETURN
  ENDIF

  ; show the MPH and SPH.
  help, coda_fetch(pf, 'MPH'), /struct
  help, coda_fetch(pf, 'SPH'), /struct

  ; get the array of DSDs, and show info of every DSD.
  dsdarray = coda_fetch(pf, 'DSD')
  FOR i=0,n_elements(dsdarray)-1 DO BEGIN
    help, coda_fetch(dsdarray[i]), /struct
  ENDFOR

  ; close the product file.
  dummy = coda_close(pf)

END
