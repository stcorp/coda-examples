#!/usr/bin/env python
#
# mipl2geo.py


import sys
import coda

if __name__ == "__main__":

    if len(sys.argv) < 2:
        print >>sys.stderr, "Usage: %s <mipas level 2 file> ..." % sys.argv[0]
        sys.exit(1)
        
    for f in sys.argv[1:]:

        pf = coda.open(f)
        product_class = coda.get_product_class(pf)
        product_type = coda.get_product_type(pf)

        if not product_class.startswith("ENVISAT") or product_type != "MIP_NL__2P":
            print >>sys.stderr, "Error: file %s is not a MIPAS Level 2 product (product class = %s, product type = %s)" % (sys.argv[1], product_class, product_type)
            sys.exit(1)

        
        print "Processing : %s" % f

        cursor = coda.Cursor()
        coda.cursor_set_product(cursor, pf)
        coda.cursor_goto_record_field_by_name(cursor, "scan_geolocation_ads")
       
        num_dsr = coda.cursor_get_num_elements(cursor)
        if num_dsr > 0:
            index = 0

            coda.cursor_goto_first_array_element(cursor)
            while index < num_dsr:
                coda.cursor_goto_record_field_by_name(cursor, "loc_mid")
                coda.cursor_goto_record_field_by_name(cursor, "latitude")
                latitude = coda.cursor_read_double(cursor)
                coda.cursor_goto_next_record_field(cursor)
                longitude = coda.cursor_read_double(cursor)
                print "latitude : %-8.4f  longitude : %-8.4f" % (latitude, longitude)
                coda.cursor_goto_parent(cursor)
                coda.cursor_goto_parent(cursor)
                index += 1
                if index < num_dsr:
                    coda.cursor_goto_next_array_element(cursor)

        coda.close(pf)
