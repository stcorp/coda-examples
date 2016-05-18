#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "coda.h"

void print_data(coda_cursor *cursor)
{
    coda_type_class type_class;

    coda_cursor_get_type_class(cursor, &type_class);
    switch (type_class)
    {
        case coda_array_class:
            {
                long num_elements;

                coda_cursor_get_num_elements(cursor, &num_elements);
                if (num_elements > 0)
                {
                    long i;

                    printf("[");
                    if (coda_cursor_goto_first_array_element(cursor) != 0)
                    {
                        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                        exit(1);
                    }
                    for (i = 0; i < num_elements; i++)
                    {
                        print_data(cursor);
                        if (i < num_elements - 1)
                        {
                            printf(", ");
                            coda_cursor_goto_next_array_element(cursor);
                        }
                    }
                    printf("]");
                    coda_cursor_goto_parent(cursor);
                }
            }
            break;
        case coda_special_class:
            {
                coda_special_type special_type;
                
                coda_cursor_get_special_type(cursor, &special_type);
                switch(special_type)
                {
                    case coda_special_time:
                        {
                            char utc_string[27];
                            double data;
            
                            if (coda_cursor_read_double(cursor, &data) != 0)
                            {
                                fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                                exit(1);
                            }
                            coda_time_to_string(data, utc_string);
                            printf("%s", utc_string);
                        }
                        break;
                    default:
                        printf("*** Unexpected special type (%s) ***", coda_type_get_special_type_name(special_type));
                }
            }
            break;
        default:
            {
                coda_native_type read_type;
                
                coda_cursor_get_read_type(cursor, &read_type);
                switch(read_type)
                {                    
                    case coda_native_type_int8:
                    case coda_native_type_int16:
                    case coda_native_type_int32:
                        {
                            int32_t data;
            
                            if (coda_cursor_read_int32(cursor, &data) != 0)
                            {
                                fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                                exit(1);
                            }
                            printf("%ld", (long)data);
                        }
                        break;
                    case coda_native_type_uint8:
                    case coda_native_type_uint16:
                    case coda_native_type_uint32:
                        {
                            uint32_t data;
            
                            if (coda_cursor_read_uint32(cursor, &data) != 0)
                            {
                                fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                                exit(1);
                            }
                            printf("%lu", (unsigned long)data);
                        }
                        break;
                    case coda_native_type_int64:
                        {
                            int64_t data;
                            char s[21];
            
                            if (coda_cursor_read_int64(cursor, &data) != 0)
                            {
                                fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                                exit(1);
                            }
                            coda_str64(data, s);
                            printf("%s", s);
                        }
                        break;
                    case coda_native_type_uint64:
                        {
                            uint64_t data;
                            char s[21];
            
                            if (coda_cursor_read_uint64(cursor, &data) != 0)
                            {
                                fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                                exit(1);
                            }
                            coda_str64u(data, s);
                            printf("%s", s);
                        }
                        break;
                    case coda_native_type_float:
                    case coda_native_type_double:
                        {
                            double data;
            
                            if (coda_cursor_read_double(cursor, &data) != 0)
                            {
                                fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                                exit(1);
                            }
                            printf("%g", data);
                        }
                        break;
                    case coda_native_type_char:
                        {
                            char data;
            
                            if (coda_cursor_read_char(cursor, &data) != 0)
                            {
                                fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                                exit(1);
                            }
                            printf("'%c'", data);
                        }
                        break;
                    case coda_native_type_string:
                        {
                            long length;
            
                            if (coda_cursor_get_string_length(cursor, &length) != 0)
                            {
                                fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                                exit(1);
                            }
                            if (length > 0)
                            {
                                char *str;
            
                                str = malloc(length + 1);
                                if (coda_cursor_read_string(cursor, str, length + 1) != 0)
                                {
                                    fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                                    exit(1);
                                }
                                printf("\"%s\"", str);
                                free(str);
                            }
                        }
                        break;
                    default:
                        printf("*** Unexpected read type (%s) ***", coda_type_get_native_type_name(read_type));
                }
            }
            break;
    }
}

void print_record(coda_cursor *cursor)
{
    long num_fields;

    if (coda_cursor_get_num_elements(cursor, &num_fields) != 0)
    {
        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
        exit(1);
    }
    if (num_fields > 0)
    {
        int i;
        coda_Type *record_type;

        coda_cursor_get_type(cursor, &record_type);
        if (coda_cursor_goto_first_record_field(cursor) != 0)
        {
            fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
            exit(1);
        }
        for (i = 0; i < num_fields; i++)
        {
            int hidden;

            /* We don't print fields that are hidden, like the first MPH field (with value 'PRODUCT=') */
            coda_type_get_record_field_hidden_status(record_type, i, &hidden);
            if (!hidden)
            {
                const char *field_name;

                coda_type_get_record_field_name(record_type, i, &field_name);

                printf("%32s : ", field_name);
                print_data(cursor);
                printf("\n");
            }
            if (i < num_fields - 1)
            {
                coda_cursor_goto_next_record_field(cursor);
            }
        }
        coda_cursor_goto_parent(cursor);
    }
}

int main(int argc, char *argv[])
{
    const char *product_class;
    coda_product *pf;
    coda_cursor cursor;
    long num_dsd;

    if (argc != 2)
    {
        fprintf(stderr, "Usage: %s <envisat file>\n", argv[0]);
        exit(1);
    }

    coda_init();
    coda_set_option_perform_conversions(0);

    if (coda_open(argv[1], &pf) != 0)
    {
        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
        exit(1);
    }

    if (coda_get_product_class(pf, &product_class) != 0)
    {
        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
        exit(1);
    }
    if (strncmp(product_class, "ENVISAT", 7) != 0)
    {
        fprintf(stderr, "Error: Not an ENVISAT product file\n");
        exit(1);
    }

    if (coda_cursor_set_product(&cursor, pf) != 0)
    {
        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
        exit(1);
    }

    printf("  MPH :\n");
    if (coda_cursor_goto_record_field_by_name(&cursor, "mph") != 0)
    {
        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
        exit(1);
    }
    print_record(&cursor);
    coda_cursor_goto_parent(&cursor);

    printf("  SPH :\n");
    if (coda_cursor_goto_record_field_by_name(&cursor, "sph") != 0)
    {
        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
        exit(1);
    }
    print_record(&cursor);
    coda_cursor_goto_parent(&cursor);

    if (coda_cursor_goto_record_field_by_name(&cursor, "dsd") != 0)
    {
        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
        exit(1);
    }
    if (coda_cursor_get_num_elements(&cursor, &num_dsd) != 0)
    {
        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
        exit(1);
    }
    if (num_dsd > 0)
    {
        int i;

        coda_cursor_goto_first_array_element(&cursor);
        for (i = 0; i < num_dsd; i++)
        {
            printf("  DSD(%d) :\n", i);
            print_record(&cursor);
            if (i < num_dsd - 1)
            {
                coda_cursor_goto_next_array_element(&cursor);
            }
        }
        coda_cursor_goto_parent(&cursor);
    }
    coda_cursor_goto_parent(&cursor);

    coda_close(pf);

    coda_done();

    return 0;
}
