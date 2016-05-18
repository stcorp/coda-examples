; This is an example for SCI_SF2_AX files.
;
; This example uses color. For this to work as intended from
; both idl and idlde, add the following four lines to your
; $HOME/.Xdefaults file:
;
; idl*gr_visual: TrueColor
; idl*gr_depth: 24
; idlde*gr_visual: TrueColor
; idlde*gr_depth: 24

PRO sciamachy_global_topography, filename

  ; open the product file. If an error occurred, report it.
  pf = coda_open(filename)
  IF coda_is_error(pf) THEN BEGIN
    print, 'Error while opening the product: ', pf.message
    RETURN
  ENDIF

  ; fetch the data.
  height = coda_fetch(pf, 'GLOBAL_TOPOGRAPHY', 0, 'height')

  ; close the product file.
  dummy = coda_close(pf)

  ; set up the Goodes Homolosine map projection
  map_set, /GOODESHOMOLOSINE

  ; warp the height-map according to the map transformation
  result = map_image(height, startx, starty, compress=1, $
                     latmin = -90, latmax = 90, lonmin = 0, lonmax = 360)

  ; plot the height map
  device, decomposed = 0, retain=2
  loadct, 27
  tvscl, result, startx, starty
  tvlct, [0],[0],[0], 255 ; map color #255 (used for the horizon) to black
  map_continents, /coasts, color=255
  map_grid, latdel = 10, londel = 10, /horizon, color=255

END
