#!/usr/bin/env python
#
# show_headers.py

import sys
import coda

def print_data(cursor):
    type_class = coda.cursor_get_type_class(cursor)
    if type_class == coda.coda_array_class:
        num_elements = coda.cursor_get_num_elements(cursor)
        if num_elements > 0:
            print "[",
            coda.cursor_goto_first_array_element(cursor)

            for i in xrange(num_elements):
                print_data(cursor)
                if i < num_elements - 1:
                    print ", ",
                    coda.cursor_goto_next_array_element(cursor)

            print "]",
            coda.cursor_goto_parent(cursor)

    elif type_class == coda.coda_special_class:
        special_type = coda.cursor_get_special_type(cursor)
        if special_type == coda.coda_special_time:
            data = coda.cursor_read_double(cursor)
            time_string = coda.time_to_string(data)
            print "%s" % time_string,
        else:
            print "*** Unexpected special type (%s) ***", coda.type_get_special_type_name(special_type),
    else:
        read_type = coda.cursor_get_read_type(cursor)
        if read_type == coda.coda_native_type_int8 or \
           read_type == coda.coda_native_type_int16 or \
           read_type == coda.coda_native_type_int32:
            data = coda.cursor_read_int32(cursor)
            print "%ld" % data,
        elif read_type == coda.coda_native_type_uint8 or \
             read_type == coda.coda_native_type_uint16 or \
             read_type == coda.coda_native_type_uint32:
            data = coda.cursor_read_uint32(cursor)
            print "%lu" % data,
        elif read_type == coda.coda_native_type_int64:
            data = coda.cursor_read_int64(cursor)
            print "%ld" % data,
        elif read_type == coda.coda_native_type_uint64:
            data = coda.cursor_read_uint64(cursor)
            print "%lu" % data,
        elif read_type == coda.coda_native_type_float or \
             read_type == coda.coda_native_type_double:
            data = coda.cursor_read_double(cursor)
            print "%g" % data,
        elif read_type == coda.coda_native_type_char:
            data = coda.cursor_read_char(cursor)
            print "'%c'" % data,
        elif read_type == coda.coda_native_type_string:
            str = coda.cursor_read_string(cursor)
            print "\"%s\"" % str,
        else:
            print "*** Unexpected read type (%s) ***", coda.type_get_native_type_name(read_type),


def print_record(cursor):
    num_fields = coda.cursor_get_num_elements(cursor)

    if num_fields > 0:
        record_type = coda.cursor_get_type(cursor)
        coda.cursor_goto_first_record_field(cursor)

        for i in xrange(num_fields):
            # We don't print fields that are hidden, like the first MPH field
            # (with value 'PRODUCT=')
            hidden = coda.type_get_record_field_hidden_status(record_type, i)
            if hidden == 0:
                field_name = coda.type_get_record_field_name(record_type, i)
                print "%32s : " % field_name,
                print_data(cursor)
                print ""

            if i < num_fields - 1:
                coda.cursor_goto_next_record_field(cursor)

        coda.cursor_goto_parent(cursor)


if __name__ == "__main__":

    if len(sys.argv) != 2:
        print >> sys.stderr, "Usage: %s <envisat file>" % sys.argv[0]
        sys.exit(1)
        
    coda.set_option_perform_conversions(0)

    pf = coda.open(sys.argv[1])
    product_class = coda.get_product_class(pf)
    if not product_class.startswith("ENVISAT"):
        print >>sys.stderr, "Error: file %s is not an ENVISAT product file (product class = %s)" % (sys.argv[1], product_class)
        sys.exit(1)

    cursor = coda.Cursor()
    coda.cursor_set_product(cursor, pf)

    print "  MPH :"
    coda.cursor_goto_record_field_by_name(cursor, "mph")
    print_record(cursor)
    coda.cursor_goto_parent(cursor)

    print "  SPH :";
    coda.cursor_goto_record_field_by_name(cursor, "sph")
    print_record(cursor);
    coda.cursor_goto_parent(cursor)

    coda.cursor_goto_record_field_by_name(cursor, "dsd")
    num_dsd = coda.cursor_get_num_elements(cursor)
    if num_dsd > 0:
        coda.cursor_goto_first_array_element(cursor)
        for i in range(num_dsd):
            print "  DSD(%d) :" % i
            print_record(cursor);

            if i < num_dsd - 1:
                coda.cursor_goto_next_array_element(cursor);

        coda.cursor_goto_parent(cursor)

    coda.cursor_goto_parent(cursor)

    coda.close(pf);
