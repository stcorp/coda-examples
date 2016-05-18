PRO mipas_level_1b, filename

  ; open the product file. If an error occurred, report it.
  pf = coda_open(filename)
  IF coda_is_error(pf) THEN BEGIN
    print, 'Error while opening the product: ', pf.message
    RETURN
  ENDIF

  ; fetch the MDS; this becomes an array of CODA_DATAHANDLEs.
  mds = coda_fetch(pf, 'mipas_level_1b_mds')

  ; traverse all measurement records.
  FOR i=0,n_elements(mds)-1 DO BEGIN

    ; fetch data for all bands.

    band_a  = coda_fetch(mds[i], "band_a")
    band_ab = coda_fetch(mds[i], "band_ab")
    band_b  = coda_fetch(mds[i], "band_b")
    band_c  = coda_fetch(mds[i], "band_c")
    band_d  = coda_fetch(mds[i], "band_d")

    ; select which bands to plot.
    plot_bands = [band_a, band_b]

    ; plot the data
    plot, plot_bands, /ylog, yrange=[1e-10,1e-4],                   $
          xtickformat='(I)', xstyle=1, psym=3,                      $
          title=STRING(format='(%"MIPAS Level-1b MDSR #%d")', i+1), $
          xtitle='readout number (bands A and B shown)',            $
          ytitle='log!I10!N(radiance) [W/(cm!E2!N !M. sr !M. cm!E-1!N)]'

  ENDFOR

  ; close the product file.
  dummy = coda_close(pf)

END
