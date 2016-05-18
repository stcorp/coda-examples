#!/usr/bin/env python
#
# absorbit.py

import sys
import coda

if __name__ == "__main__":

    if len(sys.argv) != 2:
        print >>sys.stderr, "Usage: %s <envisat file>" % sys.argv[0]
        sys.exit(1)
        
    pf = coda.open(sys.argv[1])
    product_class = coda.get_product_class(pf)
    if not product_class.startswith("ENVISAT"):
        print >>sys.stderr, "Error: file %s is not an ENVISAT product (product class = %s)" % (sys.argv[1], product_class)
        sys.exit(1)

    cursor = coda.Cursor()
    coda.cursor_set_product(cursor, pf)
    coda.cursor_goto_record_field_by_name(cursor, "mph")
    coda.cursor_goto_record_field_by_name(cursor, "abs_orbit")
    abs_orbit = coda.cursor_read_int32(cursor)

    print "absolute orbit:", abs_orbit

    coda.close(pf)
