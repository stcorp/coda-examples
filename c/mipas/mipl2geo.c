#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "coda.h"

int main(int argc, char *argv[])
{
    int f;

    if (argc < 2)
    {
        fprintf(stderr, "Usage: %s <envisat file> ...\n", argv[0]);
        exit(1);
    }

    coda_init();

    for (f = 1; f < argc; f++)
    {
        const char *product_class;
        const char *product_type;
        coda_product *pf;
        coda_cursor cursor;
        long num_dsr;

        if (coda_open(argv[f], &pf) != 0)
        {
            fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
            exit(1);
        }
        
        coda_get_product_class(pf, &product_class);
        if (strncmp(product_class, "ENVISAT", 7) != 0)
        {
            printf("Error: file %s is not an ENVISAT file\n", argv[f]);
            coda_close(pf);
            continue;
        }

        coda_get_product_type(pf, &product_type);
        if (strcmp(product_type, "MIP_NL__2P") != 0 && strcmp(product_type, "MIP_NLE_2P") != 0)
        {
            printf("Error: file %s is not a MIPAS Level 2 file\n", argv[f]);
            coda_close(pf);
            continue;
        }

        printf("Processing : %s\n", argv[f]);

        if (coda_cursor_set_product(&cursor, pf) != 0)
        {
            fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
            exit(1);
        }

        if (coda_cursor_goto_record_field_by_name(&cursor, "scan_geolocation_ads") != 0)
        {
            fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
            exit(1);
        }

        if (coda_cursor_get_num_elements(&cursor, &num_dsr) != 0)
        {
            fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
            exit(1);
        }

        if (num_dsr > 0)
        {
            int i;

            if (coda_cursor_goto_first_array_element(&cursor) != 0)
            {
                fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                exit(1);
            }
            for (i = 0; i < num_dsr; i++)
            {
                double latitude;
                double longitude;
    
                if (coda_cursor_goto_record_field_by_name(&cursor, "loc_mid") != 0)
                {
                    fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                    exit(1);
                }
                if (coda_cursor_goto_record_field_by_name(&cursor, "latitude") != 0)
                {
                    fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                    exit(1);
                }
                if (coda_cursor_read_double(&cursor, &latitude) != 0)
                {
                    fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                    exit(1);
                }
                if (coda_cursor_goto_next_record_field(&cursor) != 0)
                {
                    fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                    exit(1);
                }
                if (coda_cursor_read_double(&cursor, &longitude) != 0)
                {
                    fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                    exit(1);
                }
                printf("latitude : %-8.4f  longitude : %-8.4f\n", latitude, longitude);
                coda_cursor_goto_parent(&cursor);
                coda_cursor_goto_parent(&cursor);
                if (i < num_dsr - 1)
                {
                    if (coda_cursor_goto_next_array_element(&cursor) != 0)
                    {
                        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
                        exit(1);
                    }
                }
            }
        }

        coda_close(pf);
    }

    coda_done();

    return 0;
}
