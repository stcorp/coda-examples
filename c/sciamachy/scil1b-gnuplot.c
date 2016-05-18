
/* this example renders the readouts of a SCIAMACHY level-1b file
 * as GNUPLOT commands. You can pipe this directly into gnuplot,
 * or redirect this to a file to read later on.
 */

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "coda.h"

#define NO_VALUE -999

double pixel_array[8][1024];    /* calibrated pixel readouts     */
double lambda[8][1024]; /* wavelength of detector pixels */
double fpn[8][1024];    /* fixed pattern noise           */
double leak[8][1024];   /* leakage current               */
uint8_t badpx[8][1024]; /* bad pixel map                 */

void init(coda_product *pf)
{
    coda_cursor cursor;

    coda_cursor_set_product(&cursor, pf);

    /* Read wavelengths of detector pixels */
    coda_cursor_goto_record_field_by_name(&cursor, "spectral_base");
    coda_cursor_goto_array_element_by_index(&cursor, 0);
    coda_cursor_goto_record_field_by_name(&cursor, "wvlen_det_pix");
    coda_cursor_read_double_array(&cursor, &lambda[0][0], coda_array_ordering_c);
    coda_cursor_goto_root(&cursor);

    /* Read fixed pattern noise data */
    coda_cursor_goto_record_field_by_name(&cursor, "leakage_constant");
    coda_cursor_goto_array_element_by_index(&cursor, 0);
    coda_cursor_goto_record_field_by_name(&cursor, "fpn_const");
    coda_cursor_read_double_array(&cursor, &fpn[0][0], coda_array_ordering_c);

    /* Read leakage current data */
    coda_cursor_goto_parent(&cursor);
    coda_cursor_goto_record_field_by_name(&cursor, "leak_const");
    coda_cursor_read_double_array(&cursor, &leak[0][0], coda_array_ordering_c);
    coda_cursor_goto_root(&cursor);

    /* Read bad pixel map */
    coda_cursor_goto_record_field_by_name(&cursor, "ppg_etalon");
    coda_cursor_goto_array_element_by_index(&cursor, 0);
    coda_cursor_goto_record_field_by_name(&cursor, "bad_pix_mask");
    coda_cursor_read_uint8_array(&cursor, &badpx[0][0], coda_array_ordering_c);
    coda_cursor_goto_root(&cursor);
}

void display_pixel_array(double pixel_array[8][1024], char *filename, long stateNr, const char *state_name, long mdsrNr)
{
    int ch, px;

    /* we display the MDSR record number 1-based */
    printf("set title '%s STATE: %ld (%s) MDSR: %ld';\n", filename, stateNr + 1, state_name, mdsrNr + 1);

    printf("plot '-' with lines linetype 1, '-' with lines linetype 2, '-' with lines linetype 3, "
           "'-' with lines linetype 4, '-' with lines linetype 5, '-' with lines linetype 6, "
           "'-' with lines linetype 7, '-' with lines linetype 8;\n");

    for (ch = 0; ch < 8; ch++)
    {
        int previous_ok = 0;

        for (px = 0; px < 1024; px++)
        {
            double value = pixel_array[ch][px];

            if (value < 1e-2)
            {
                if (previous_ok)
                {
                    printf("\n");
                    previous_ok = 0;
                }
            }
            else
            {
                printf("%f %f\n", lambda[ch][px], value);
                previous_ok = 1;
            }
        }
        printf("e\n");
    }
}

void process_states(coda_product *pf, char *filename)
{
    const char *state_name[] = { "no measurement", "nadir", "limb", "occultation", "monitoring" };
    long stateNr, num_states, i;

    coda_cursor states_cursor;
    coda_cursor mds_cursor[5];  /* 1 dummy + 4x MDS : empty, nadir, limb, occultation, monitoring */

    /* Initialize STATES cursor */

    coda_cursor_set_product(&states_cursor, pf);
    coda_cursor_goto_record_field_by_name(&states_cursor, "states");
    coda_cursor_get_num_elements(&states_cursor, &num_states);
    if (num_states == 0)
    {
        return;
    }
    coda_cursor_goto_first_array_element(&states_cursor);       /* go to first state */

    /* initialize MDS cursors */

    for (i = 1; i <= 4; i++)    /* skip #0 (dummy MDS cursor) */
    {
        int available;
        long field_index;

        coda_cursor_set_product(&mds_cursor[i], pf);
        coda_cursor_get_record_field_index_from_name(&mds_cursor[i], state_name[i], &field_index);
        coda_cursor_get_record_field_available_status(&mds_cursor[i], field_index, &available);
        if (available)
        {
            coda_cursor_goto_record_field_by_name(&mds_cursor[i], state_name[i]);
            coda_cursor_goto_first_array_element(&mds_cursor[i]);
        }
    }

    /* now walk the states */
    for (stateNr = 0; stateNr < num_states; stateNr++)
    {
        uint8_t mds_type;
        uint16_t num_clus;
        uint16_t num_dsr;
        int dsrNr;

        /* Read mds_type, num_clus, and num_dsr for this state */
        coda_cursor_goto_record_field_by_name(&states_cursor, "mds_type");
        coda_cursor_read_uint8(&states_cursor, &mds_type);
        coda_cursor_goto_parent(&states_cursor);
        coda_cursor_goto_record_field_by_name(&states_cursor, "num_clus");
        coda_cursor_read_uint16(&states_cursor, &num_clus);
        coda_cursor_goto_parent(&states_cursor);
        coda_cursor_goto_record_field_by_name(&states_cursor, "num_dsr");
        coda_cursor_read_uint16(&states_cursor, &num_dsr);
        coda_cursor_goto_parent(&states_cursor);

        fprintf(stderr, "Processing state %ld of %ld\n", stateNr + 1, num_states);
        fprintf(stderr, "  mds_type .....: %d (%s)\n", mds_type, state_name[mds_type]);
        fprintf(stderr, "  num_clus .....: %d\n", num_clus);
        fprintf(stderr, "  num_dsr ......: %d\n", num_dsr);

        /* traverse the MDSRs for this state */
        for (dsrNr = 0; dsrNr < num_dsr; dsrNr++)
        {
            coda_cursor clus_config_cursor;
            coda_cursor clus_dat_cursor;
            int cluster;
            uint8_t chan_num;
            int pixelNr;

            /* Initialize pixel_array with zeros */
            for (chan_num = 0; chan_num < 8; chan_num++)
            {
                for (pixelNr = 0; pixelNr < 1024; pixelNr++)
                {
                    pixel_array[chan_num][pixelNr] = 0.0;
                }
            }

            clus_config_cursor = states_cursor;
            coda_cursor_goto_record_field_by_name(&clus_config_cursor, "clus_config");
            coda_cursor_goto_first_array_element(&clus_config_cursor);

            clus_dat_cursor = mds_cursor[mds_type];
            coda_cursor_goto_record_field_by_name(&clus_dat_cursor, "clus_dat");
            coda_cursor_goto_first_array_element(&clus_dat_cursor);

            /* traverse the clusters in this MDSR */
            for (cluster = 0; cluster < num_clus; cluster++)
            {
                uint16_t start_pix;
                uint16_t clus_len;
                double pet;
                double intgr_time;
                uint16_t coadd_factor;
                uint16_t num_readouts;
                uint8_t clus_data_type;
                double it;
                int readoutNr;

                /* Read clus_config */
                coda_cursor_goto_record_field_by_name(&clus_config_cursor, "chan_num");
                coda_cursor_read_uint8(&clus_config_cursor, &chan_num);
                coda_cursor_goto_parent(&clus_config_cursor);
                chan_num--;
                coda_cursor_goto_record_field_by_name(&clus_config_cursor, "start_pix");
                coda_cursor_read_uint16(&clus_config_cursor, &start_pix);
                coda_cursor_goto_parent(&clus_config_cursor);
                coda_cursor_goto_record_field_by_name(&clus_config_cursor, "clus_len");
                coda_cursor_read_uint16(&clus_config_cursor, &clus_len);
                coda_cursor_goto_parent(&clus_config_cursor);
                coda_cursor_goto_record_field_by_name(&clus_config_cursor, "pet");
                coda_cursor_read_double(&clus_config_cursor, &pet);
                coda_cursor_goto_parent(&clus_config_cursor);
                coda_cursor_goto_record_field_by_name(&clus_config_cursor, "intgr_time");
                coda_cursor_read_double(&clus_config_cursor, &intgr_time);
                coda_cursor_goto_parent(&clus_config_cursor);
                coda_cursor_goto_record_field_by_name(&clus_config_cursor, "coadd_factor");
                coda_cursor_read_uint16(&clus_config_cursor, &coadd_factor);
                coda_cursor_goto_parent(&clus_config_cursor);
                coda_cursor_goto_record_field_by_name(&clus_config_cursor, "num_readouts");
                coda_cursor_read_uint16(&clus_config_cursor, &num_readouts);
                coda_cursor_goto_parent(&clus_config_cursor);
                coda_cursor_goto_record_field_by_name(&clus_config_cursor, "clus_data_type");
                coda_cursor_read_uint8(&clus_config_cursor, &clus_data_type);
                coda_cursor_goto_parent(&clus_config_cursor);

                /* The integration time is not allways equal to intgr_time/16
                 * since the integration time is sometimes equal to 1/32 which
                 * can not be expressed with the intgr_time field. So always use
                 * 'coadd_factor * pet' to calculate the integration time.
                 */

                it = coadd_factor * pet;

                /* Read clus_dat */
                if (clus_data_type == 1)
                {
                    coda_cursor_goto_record_field_by_name(&clus_dat_cursor, "sig");
                }
                else
                {
                    coda_cursor_goto_record_field_by_name(&clus_dat_cursor, "sigc");
                }

                coda_cursor_goto_first_array_element(&clus_dat_cursor);
                for (readoutNr = 0; readoutNr < num_readouts; readoutNr++)
                {
                    for (pixelNr = start_pix; pixelNr < start_pix + clus_len; pixelNr++)
                    {
                        double signal;

                        /* Read signal */
                        coda_cursor_goto_record_field_by_name(&clus_dat_cursor, "signal");

                        coda_cursor_read_double(&clus_dat_cursor, &signal);
                        pixel_array[chan_num][pixelNr] += signal;

                        coda_cursor_goto_parent(&clus_dat_cursor);

                        if (readoutNr < num_readouts - 1 || pixelNr < start_pix + clus_len - 1)
                        {
                            coda_cursor_goto_next_array_element(&clus_dat_cursor);
                        }
                    }
                }

                coda_cursor_goto_parent(&clus_dat_cursor);      /* back to array */
                coda_cursor_goto_parent(&clus_dat_cursor);      /* back to record */

                for (pixelNr = start_pix; pixelNr < start_pix + clus_len; pixelNr++)
                {
                    /* Take average */
                    pixel_array[chan_num][pixelNr] /= num_readouts;

                    /* Perform correction for fixed pattern noise and leakage current */
                    pixel_array[chan_num][pixelNr] =
                        pixel_array[chan_num][pixelNr] / it - fpn[chan_num][pixelNr] / pet - leak[chan_num][pixelNr];
                }

                if (cluster < num_clus - 1)
                {
                    coda_cursor_goto_next_array_element(&clus_config_cursor);
                    coda_cursor_goto_next_array_element(&clus_dat_cursor);
                }
            }

            /* Apply bad pixel map */
            for (chan_num = 0; chan_num < 8; chan_num++)
            {
                for (pixelNr = 0; pixelNr < 1024; pixelNr++)
                {
                    if (badpx[chan_num][pixelNr])
                    {
                        pixel_array[chan_num][pixelNr] = NO_VALUE;
                    }
                }
            }

            coda_cursor_goto_next_array_element(&mds_cursor[mds_type]);

            /* make the gnuplot */
            {
                long mdsrNr;

                coda_cursor_get_index(&mds_cursor[mds_type], &mdsrNr);
                display_pixel_array(pixel_array, filename, stateNr, state_name[mds_type], mdsrNr);
            }

        }

        if (stateNr < num_states - 1)
        {
            coda_cursor_goto_next_array_element(&states_cursor);
        }
    }
}

int main(int argc, char *argv[])
{
    const char *product_class;
    const char *product_type;
    coda_product *pf;

    if (argc < 2)
    {
        fprintf(stderr, "Usage: %s <sciamachy level 1b product>\n", argv[0]);
        exit(1);
    }

    coda_init();
    coda_set_option_perform_boundary_checks(0);

    if (coda_open(argv[1], &pf) != 0)
    {
        fprintf(stderr, "Error: %s\n", coda_errno_to_string(coda_errno));
        exit(1);
    }

    coda_get_product_class(pf, &product_class);
    coda_get_product_type(pf, &product_type);
    if (strncmp(product_class, "ENVISAT", 7) != 0 || strcmp(product_type, "SCI_NL__1P") != 0)
    {
        fprintf(stderr, "Error: Not a SCIAMACHY Level 1b product\n");
        exit(1);
    }

    printf("set xrange [200:2500];\n");
    printf("set yrange [1e-2:1e7];\n");
    printf("set xtics (200,300,400,600,900,1200,1500,2000,2500);\n");
    printf("set logscale y 10;\n");
    printf("set xlabel 'wavelength [nm]';\n");
    printf("set ylabel 'signal [BU/s]';\n");
    printf("set nokey;\n");

    init(pf);

    process_states(pf, argv[1]);

    coda_close(pf);

    coda_done();

    return 0;
}
