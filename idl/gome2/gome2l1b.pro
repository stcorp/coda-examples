pro gome2l1b, filename
   pf = coda_open(filename)
   ; this returns a list of coda datahandles to the MDRs
   mdr = coda_fetch(pf, 'MDR')
   num_mdr = n_elements(mdr)
   for i = 0L, num_mdr-1L do begin
      ; This checks for 'Earthshine'
      ; You can do a similar check if you just want
      ; 'Calibration', 'Sun', or 'Moon' data
      if coda_fieldavailable(mdr[i], 'Eartshine') then begin
         ; Note that this will not extract the whole MDR
         ; The band data is still available as datahandles
         record = coda_fetch(mdr[i], 'Earthshine')
         help, record, /struct
         ; To extract just the wavelength and band data it is better to use
         ;   wavelength = coda_fetch(mdr[i], 'Earthshine', 'wavelength_1b')
         ;   rad = coda_fetch(mdr[i], 'Earthshine', 'band_1b', [-1,-1], 'rad')
         ;   err = coda_fetch(mdr[i], 'Earthshine', 'band_1b', [-1,-1], 'err_rad')
      endif
   endfor
   dummy = coda_close(pf)
end
