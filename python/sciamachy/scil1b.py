#!/usr/bin/env python
#
# scil1b.py


import sys
import coda
import numpy
import copy

NO_VALUE = coda.NaN()

global fpn,leak,badpx

def init(pf):
    global fpn,leak,badpx
    
    cursor = coda.Cursor()

    coda.cursor_set_product(cursor, pf)

    # Read wavelengths of detector pixels
    coda.cursor_goto_record_field_by_name(cursor, "spectral_base")
    coda.cursor_goto_array_element_by_index(cursor, 0)
    coda.cursor_goto_record_field_by_name(cursor, "wvlen_det_pix")
    wave_lengths = coda.cursor_read_double_array(cursor)
    coda.cursor_goto_root(cursor)

    # Read fixed pattern noise data
    coda.cursor_goto_record_field_by_name(cursor, "leakage_constant")
    coda.cursor_goto_array_element_by_index(cursor, 0)
    coda.cursor_goto_record_field_by_name(cursor, "fpn_const")
    fpn = coda.cursor_read_double_array(cursor)

    # Read leakage current data
    coda.cursor_goto_parent(cursor)
    coda.cursor_goto_record_field_by_name(cursor, "leak_const")
    leak = coda.cursor_read_double_array(cursor)
    coda.cursor_goto_root(cursor)

    # Read bad pixel map
    coda.cursor_goto_record_field_by_name(cursor, "ppg_etalon")
    coda.cursor_goto_array_element_by_index(cursor, 0)
    coda.cursor_goto_record_field_by_name(cursor, "bad_pix_mask")
    badpx = coda.cursor_read_uint8_array(cursor)
    coda.cursor_goto_root(cursor)


def process_states(pf):
    global fpn,leak,badpx
    
    state_name = [ "no measurement", "nadir", "limb", "occultation", "monitoring" ]

    states_cursor = coda.Cursor()
    mds_cursor = [coda.Cursor() for i in range(0,5)]
    pixel_array = numpy.zeros(shape=(8,1024),dtype=numpy.float64)
#    coda.Cursor mds_cursor[5]  /* 1 dummy + 4x MDS : empty, nadir, limb, occultation, monitoring */


    # Initialize STATES cursor
    coda.cursor_set_product(states_cursor, pf)
    coda.cursor_goto_record_field_by_name(states_cursor, "states")
    num_states = coda.cursor_get_num_elements(states_cursor)
    if (num_states == 0):
        return
    coda.cursor_goto_first_array_element(states_cursor)

    # Initialize MDS cursors
    # Skip #0 (dummy MDS cursor)
    for i in range(1,5):
        coda.cursor_set_product(mds_cursor[i], pf)
        record_type = coda.cursor_get_type(mds_cursor[i])
        field_index = coda.type_get_record_field_index_from_name(record_type, state_name[i])
        available = coda.cursor_get_record_field_available_status(mds_cursor[i], field_index)
        if (available):
            coda.cursor_goto_record_field_by_name(mds_cursor[i], state_name[i])
            coda.cursor_goto_first_array_element(mds_cursor[i])

    # now walk the states
    for stateNr in range(0,num_states):
        # Read mds_type, num_clus, and num_dsr for this state
        coda.cursor_goto_record_field_by_name(states_cursor, "mds_type")
        mds_type = coda.cursor_read_uint8(states_cursor)
        coda.cursor_goto_parent(states_cursor)
        coda.cursor_goto_record_field_by_name(states_cursor, "num_clus")
        num_clus = coda.cursor_read_uint16(states_cursor)
        coda.cursor_goto_parent(states_cursor)
        coda.cursor_goto_record_field_by_name(states_cursor, "num_dsr")
        num_dsr = coda.cursor_read_uint16(states_cursor)
        coda.cursor_goto_parent(states_cursor)

        print "Processing state %d of %d" % (stateNr + 1, num_states)
        print "  mds_type .....: %d (%s)" % (mds_type, state_name[mds_type])
        print "  num_clus .....: %d" % (num_clus,)
        print "  num_dsr ......: %d" % (num_dsr,)

        # traverse the MDSRs for this state */
        for dsrNr in range(0,num_dsr):
#            clus_config_cursor = coda.Cursor()
#            clus_dat_cursor = coda.Cursor()

            # Initialize pixel_array with zeros
            for chan_num in range(0,8):
                for pixelNr in range(0,1024):
                    pixel_array[chan_num][pixelNr] = 0.0

            clus_config_cursor = copy.deepcopy(states_cursor)
            coda.cursor_goto_record_field_by_name(clus_config_cursor, "clus_config")
            coda.cursor_goto_first_array_element(clus_config_cursor)
            
            
            clus_dat_cursor = copy.deepcopy(mds_cursor[mds_type])
            coda.cursor_goto_record_field_by_name(clus_dat_cursor, "clus_dat")
            coda.cursor_goto_first_array_element(clus_dat_cursor)

            # traverse the clusters in this MDSR
            for cluster in range(0,num_clus):
                # Read clus_config
                coda.cursor_goto_record_field_by_name(clus_config_cursor, "chan_num")
                chan_num = coda.cursor_read_uint8(clus_config_cursor)
                coda.cursor_goto_parent(clus_config_cursor)
                chan_num -= 1
                coda.cursor_goto_record_field_by_name(clus_config_cursor, "start_pix")
                start_pix = coda.cursor_read_uint16(clus_config_cursor)
                coda.cursor_goto_parent(clus_config_cursor)
                coda.cursor_goto_record_field_by_name(clus_config_cursor, "clus_len")
                clus_len = coda.cursor_read_uint16(clus_config_cursor)
                coda.cursor_goto_parent(clus_config_cursor)
                coda.cursor_goto_record_field_by_name(clus_config_cursor, "pet")
                pet = coda.cursor_read_double(clus_config_cursor)
                coda.cursor_goto_parent(clus_config_cursor)
                coda.cursor_goto_record_field_by_name(clus_config_cursor, "intgr_time")
                intgr_time = coda.cursor_read_double(clus_config_cursor)
                coda.cursor_goto_parent(clus_config_cursor)
                coda.cursor_goto_record_field_by_name(clus_config_cursor, "coadd_factor")
                coadd_factor = coda.cursor_read_uint16(clus_config_cursor)
                coda.cursor_goto_parent(clus_config_cursor)
                coda.cursor_goto_record_field_by_name(clus_config_cursor, "num_readouts")
                num_readouts = coda.cursor_read_uint16(clus_config_cursor)
                coda.cursor_goto_parent(clus_config_cursor)
                coda.cursor_goto_record_field_by_name(clus_config_cursor, "clus_data_type")
                clus_data_type = coda.cursor_read_uint8(clus_config_cursor)
                coda.cursor_goto_parent(clus_config_cursor)

                # The integration time is not allways equal to intgr_time/16
                # since the integration time is sometimes equal to 1/32 which
                # can not be expressed with the intgr_time field. So always use
                # 'coadd_factor * pet' to calculate the integration time.

                it = coadd_factor * pet

                # Read clus_dat
                if (clus_data_type == 1):
                    coda.cursor_goto_record_field_by_name(clus_dat_cursor, "sig")
                else:
                    coda.cursor_goto_record_field_by_name(clus_dat_cursor, "sigc")

                coda.cursor_goto_first_array_element(clus_dat_cursor)
                for readoutNr in range(0,num_readouts):
                    for pixelNr in range(start_pix,start_pix + clus_len):
                        # Read signal
                        coda.cursor_goto_record_field_by_name(clus_dat_cursor, "signal")

                        signal = coda.cursor_read_double(clus_dat_cursor)
                        pixel_array[chan_num][pixelNr] += signal

                        coda.cursor_goto_parent(clus_dat_cursor)

                        if ((readoutNr < num_readouts - 1) or (pixelNr < start_pix + clus_len - 1)):
                            coda.cursor_goto_next_array_element(clus_dat_cursor)

                coda.cursor_goto_parent(clus_dat_cursor)      # back to array
                coda.cursor_goto_parent(clus_dat_cursor)      # back to record

                for pixelNr in range(start_pix,start_pix + clus_len):
                    # Take average
                    pixel_array[chan_num][pixelNr] /= num_readouts

                    # Perform correction for fixed pattern noise and leakage current
                    pixel_array[chan_num][pixelNr] = pixel_array[chan_num][pixelNr] / it - fpn[chan_num][pixelNr] / pet - leak[chan_num][pixelNr]

                if (cluster < num_clus - 1):
                    coda.cursor_goto_next_array_element(clus_config_cursor)
                    coda.cursor_goto_next_array_element(clus_dat_cursor)

            # Apply bad pixel map
            for chan_num in range(0,8):
                for pixelNr in range(0,1024):
                    if (badpx[chan_num][pixelNr]):
                        pixel_array[chan_num][pixelNr] = NO_VALUE

            coda.cursor_goto_next_array_element(mds_cursor[mds_type])

        if (stateNr < num_states - 1):
            coda.cursor_goto_next_array_element(states_cursor)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print >>sys.stderr, "Usage: %s <sciamachy level 1b product>" % sys.argv[0]
        sys.exit(1)
        
    coda.set_option_perform_boundary_checks(0)

    pf = coda.open(sys.argv[1])
    product_class = coda.get_product_class(pf)
    product_type = coda.get_product_type(pf)
    if not product_class.startswith("ENVISAT") or product_type != "SCI_NL__1P":
        print >>sys.stderr, "Error: file %s is not a SCIAMACHY Level 1b product (product class = %s, product type = %s)" % (sys.argv[1], product_class, product_type)
        sys.exit(1)

    init(pf)
    process_states(pf)

    coda.close(pf)
