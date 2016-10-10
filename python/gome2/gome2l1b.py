import coda

pf = coda.open('/data/GOME2/GOME_xxx_1B/GOME_xxx_1B_M02_20100415122955Z_20100415123255Z_N_T_20100713095647Z')
cursor = coda.Cursor()
coda.cursor_set_product(cursor, pf)
coda.cursor_goto(cursor, '/MDR')
num_mdr = coda.cursor_get_num_elements(cursor)
if num_mdr > 0:
    coda.cursor_goto_first_array_element(cursor)
    for i in xrange(num_mdr):
        index = coda.cursor_get_available_union_field_index(cursor)
        if index == 0:
            # Earthshine MDR
            # Note that fetching the full MDR is rather slow, since it converts
            # the full MDR to a hierarchicel set of Python structures
            mdr = coda.fetch(cursor, 'Earthshine')
            print mdr
            # If you want e.g. just the wavelength and band data of band 1b, you could use:
            #   wavelength = coda.fetch(cursor, 'Earthshine', 'wavelength_1b')
            #   rad = coda.fetch(cursor, 'Earthshine', 'band_1b', [-1,-1], 'rad')
            #   err = coda.fetch(cursor, 'Earthshine', 'band_1b', [-1,-1], 'err_rad')
            # which will be much faster
        elif index == 1:
            # Calibration MDR
            pass
        elif index == 2:
            # Sun MDR
            mdr = coda.fetch(cursor, 'Sun')
            print mdr
        elif index == 3:
            # Moon MDR
            mdr = coda.fetch(cursor, 'Moon')
            print mdr
        if i < num_mdr - 1:
            coda.cursor_goto_next_array_element(cursor)
del cursor
coda.close(pf)
