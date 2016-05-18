#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "coda.h"

int main(int argc, char *argv[])
{
    const char* product_class;
    coda_product *pf;
    coda_cursor cursor;
    int32_t abs_orbit;
    int result;

    if (argc != 2)
    {
        fprintf(stderr, "Usage: %s <envisat file>\n", argv[0]);
        exit(1);
    }

    coda_init();

    result = coda_open(argv[1], &pf);
    if (result != 0)
    {
        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
        exit(1);
    }

    result = coda_get_product_class(pf, &product_class);
    if (result != 0)
    {
        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
        exit(1);
    }
    if (strncmp(product_class, "ENVISAT", 7) != 0)
    {
        fprintf(stderr, "Error: file %s is not an ENVISAT product\n", argv[1]);
        exit(1);
    }

    result = coda_cursor_set_product(&cursor, pf);
    if (result != 0)
    {
        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
        exit(1);
    }

    result = coda_cursor_goto_record_field_by_name(&cursor, "mph");
    if (result != 0)
    {
        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
        exit(1);
    }

    result = coda_cursor_goto_record_field_by_name(&cursor, "abs_orbit");
    if (result != 0)
    {
        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
        exit(1);
    }

    result = coda_cursor_read_int32(&cursor, &abs_orbit);
    if (result != 0)
    {
        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
        exit(1);
    }

    printf("absolute orbit: %d\n", (int)abs_orbit);

    coda_close(pf);

    coda_done();

    return 0;
}
