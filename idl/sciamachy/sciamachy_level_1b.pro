PRO sciamachy_level_1b, filename

  enable_dump    = 0
  enable_readout = 1
  enable_plots   = 1

  pixel_array = dblarr(8, 1024)

  pf = coda_open(filename)
  IF coda_is_error(pf) THEN BEGIN
    print, 'Error while opening the product: ', pf.message
    RETURN
  ENDIF

  print, 'Fetching entire product from file "' + filename + '"...'

  product = coda_fetch(pf)
  IF coda_is_error(product) THEN BEGIN
    print, 'Error while fetching the product: ', product.message
    RETURN
  ENDIF

  lambda = coda_fetch(product.spectral_base   [0], 'wvlen_det_pix')
  fpn    = coda_fetch(product.leakage_constant[0], 'fpn_const')
  leak   = coda_fetch(product.leakage_constant[0], 'leak_const')
  badpx  = coda_fetch(product.ppg_etalon      [0], 'bad_pix_mask' )
  sunref = coda_fetch(product.sun_reference   [0], 'mean_ref_spec')

  print, 'Done.'

  device, decomposed = 0, retain=2
  window, xsize=800, ysize=600
  loadct, 27

  ; set number-of-records-read to zero for all four kinds of records

  rec_mds_nadir = 0
  rec_mds_limb  = 0
  rec_mds_occ   = 0
  rec_mds_mon   = 0

  FOR stateNr = 0, n_elements(product.states)-1 DO BEGIN

    ; get MDS type for this state.
    ; 1=NADIR, 2=LIMB, 3=OCCULTATION, 4-MONITORING

    state = coda_fetch(product.states[stateNr])

    print, 'Processing state ', (stateNr+1), ' of ', n_elements(product.states)
    print, '  mds_type...:', state.mds_type
    print, '  num_clus...:', state.num_clus
    print, '  num_dsr....:', state.num_dsr

    FOR dsrNr = 0, state.num_dsr-1 DO BEGIN

      CASE state.mds_type OF
        0: BEGIN
             state_name = 'NO MEASUREMENT'
             dsr_time = 0
           END
        1: BEGIN
             state_name = 'NADIR'
             clus_dat = coda_fetch(product.nadir[rec_mds_nadir], 'clus_dat')
             dsr_time = coda_fetch(product.nadir[rec_mds_nadir], 'dsr_time')
             recno = rec_mds_nadir
             rec_mds_nadir = rec_mds_nadir + 1
           END
        2: BEGIN
             state_name = 'LIMB'
             clus_dat = coda_fetch(product.limb[rec_mds_limb], 'clus_dat')
             dsr_time = coda_fetch(product.limb[rec_mds_limb], 'dsr_time')
             recno = rec_mds_limb
             rec_mds_limb  = rec_mds_limb + 1
           END
        3: BEGIN
             state_name = 'OCCULTATION'
             clus_dat = coda_fetch(product.occultation[rec_mds_occ], 'clus_dat')
             dsr_time = coda_fetch(product.occultation[rec_mds_occ], 'dsr_time')
             recno = rec_mds_occ
             rec_mds_occ   = rec_mds_occ + 1
           END
        4: BEGIN
             state_name = 'MONITORING'
             clus_dat = coda_fetch(product.monitoring[rec_mds_mon], 'clus_dat')
             dsr_time = coda_fetch(product.monitoring[rec_mds_mon], 'dsr_time')
             recno = rec_mds_mon
             rec_mds_mon   = rec_mds_mon + 1
           END
      ENDCASE

      time_str = coda_time_to_string(dsr_time)

      pixel_array[*,*] = 0D

      ; traverse the clusters for this state
      FOR cluster = 0, state.num_clus-1 DO BEGIN

        clus_config  = coda_fetch(state.clus_config[cluster])

        it_as_stated     = clus_config.intgr_time
        it_as_calculated = clus_config.coadd_factor*clus_config.pet

        IF it_as_stated NE it_as_calculated THEN BEGIN
          print, 'WARNING: integration time stated is not equal to coadd_factor*pet!'
        ENDIF

        IF enable_dump THEN BEGIN

          print, '#  cluster_id.......: ', clus_config.cluster_id
          print, '   chan_num.........: ', clus_config.chan_num
          print, '   start_pix........: ', clus_config.start_pix
          print, '   clus_len.........: ', clus_config.clus_len
          print, '   PET..............: ', clus_config.pet
          print, '   intgr_time.......: ', it_as_stated
          print, '   coadd_factor.....: ', clus_config.coadd_factor
          print, '   num_readouts.....: ', clus_config.num_readouts
          print, '   clus_data_type...: ', clus_config.clus_data_type

        ENDIF

        IF enable_readout THEN BEGIN

          CASE clus_config.clus_data_type OF
            1: readouts = coda_fetch(clus_dat[cluster], 'sig' )
            2: readouts = coda_fetch(clus_dat[cluster], 'sigc')
          ENDCASE
 
          ; note that, we read all cluster readouts, and then we average over
          ; the number of readouts to obtain the signal value for the clusters.

          FOR i=0, clus_config.num_readouts-1 DO BEGIN
            FOR j=0, clus_config.clus_len-1 DO BEGIN

              chNr = clus_config.chan_num-1
              pxNr = clus_config.start_pix+j

              ; solve the following equation for 'signal': this handles
              ; fixed-pattern noise and leakage current.
              ;
              ; readout[BU] = coadd_factor * (signal[BU/s] * pet[s] + fpn[BU] + leak[BU/s]*pet[s])

              signal = coda_fetch(readouts[i,j], 'signal')/it_as_calculated - $
                       fpn[chNr, pxNr]/clus_config.pet - $
                       leak[chNr, pxNr]

              ; add to pixel_array and take averages
              pixel_array[chNr, pxNr] = pixel_array[chNr, pxNr] + signal/clus_config.num_readouts

            ENDFOR
          ENDFOR

      ENDIF ; readout enabled?

      ENDFOR ; done processing all clusters

      ; NaNify all bad pixels
      badpx_index = WHERE(badpx EQ 1, badpx_count)
      IF badpx_count NE 0 THEN pixel_array[badpx_index] = !VALUES.D_NAN

      ; pixel_array = sunref / pixel_array ; divide by sun spectrum

      IF enable_readout AND enable_plots THEN BEGIN

        tvec = [200,300,400,600,800,1200,1800,2400]

        plot, lambda, pixel_array[0,*], /ylog, yrange=[1E-2,1E7], xstyle=1, /nodata, $
          title=string(format='(%"state #%d (%s, DSR#%d): %s")', stateNr+1, state_name, recno+1, time_str), xticks=n_elements(tvec)-1, $
          xtitle = 'wavelength [nm]', ytitle = 'readout [BU/s]'

        FOR i=0,7 DO BEGIN
          oplot, lambda[i,*], pixel_array[i,*], color= (i MOD 4)*40+10
        ENDFOR

        WAIT, 0.1

      ENDIF

    ENDFOR ; done processing all DSRs for this state

  ENDFOR ; done processing all states

  dummy = coda_close(pf)

END
