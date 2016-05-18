PRO gomos_level_1b, filename

  device, decomposed=0
  loadct, 27
  tvlct, [0],[0],[0], 255  ; map color #255 to black

  ; open the product file. If an error occurred, report it.
  pf = coda_open(filename)
  IF coda_is_error(pf) THEN BEGIN
    print, 'Error while opening the product: ', pf.message
    RETURN
  ENDIF

  bright_limb = coda_fetch(pf, 'sph', 'bright_limb')
  star_mag    = coda_fetch(pf, 'sph', 'star_mag')

  ; fetch the data: star name, pixel-to-wavelength map, TRANSMISSION MDS.
  starname   = coda_fetch(pf, 'sph', 'star')
  lambda_map = coda_fetch(pf, 'tra_nom_wav_assignment', 0, 'nom_wl')
  trans_mds  = coda_fetch(pf, 'tra_transmission')

  ; determine start-time. This is useful for providing display of
  ; time since start-of-occultation.
  Tstart = coda_fetch(trans_mds[0], 'dsr_time')

  ; traverse the TRANSMISSION records.
  FOR i=0, n_elements(trans_mds)-1 DO BEGIN

    ; fetch time and spectrum contained in this MDSR.
    T        = coda_fetch(trans_mds[i], 'dsr_time')
    spectrum = coda_fetch(trans_mds[i], 'trans_spectra')

    ; plot the spectrum and some annotation info.
    plot, lambda_map, spectrum,                                      $
          xstyle = 1, ystyle = 1,                                    $
          yrange = [-0.2, 1.2],                                      $
          title  = STRING(format='(%"star: %s magnitude: %6.3f time: %s (%6.3f s)")', $
                 starname, star_mag, coda_time_to_string(T), (T-Tstart)),    $
          xtitle = 'wavelength [nm]', ytitle = 'transmission [-]', color=255

    ; small pause for animation
    wait, 0.1

  ENDFOR

  ; close the product file.
  dummy = coda_close(pf)

END
