      program scil1b

      implicit none

      external length
      integer length

      include "coda.inc"

      integer stderr
      parameter (stderr = 0)

C use 'integer*8 pf' for 64-bit
      integer pf
C use 'integer*8 cursor' for 64-bit
      integer cursor
C use 'integer*8 mds_cursor' for 64-bit
      integer mds_cursor
      dimension mds_cursor(4)
C use 'integer*8 clus_config_cursor' for 64-bit
      integer clus_config_cursor
C use 'integer*8 clus_dat_cursor' for 64-bit
      integer clus_dat_cursor
      integer result
      character*1024 filename
      character*32 product_class
      character*32 product_type
      double precision it
      double precision signal
      integer badpx
      integer stateNr
C use 'integer*8 num_states' for 64-bit
      integer num_states
      integer available
      integer mds_type
      integer num_clus
      integer num_dsr
      integer dsrNr
      integer cluster
      integer chan_num
      integer pixelNr
      integer start_pix
      integer clus_len
      integer intgr_time
      integer coadd_factor
      integer num_readouts
      integer clus_data_type
      integer readoutNr
C use 'integer*8 field_index' for 64-bit
      integer field_index
      integer i
C
C Multidimensional array data in an ENVISAT product file is stored
C using C array ordering.
C BEAT allows two ways to read such array data in Fortran:
C 1) Use coda_cursor_read_..._array(..., ..., coda_array_ordering_c) and
C    reverse the dimensions of your local variables. For example, if
C    the data was stored as a [8,1024] array declare your local
C    variable using 'dimension ...(1024,8)'.
C 2) Use coda_cursor_read_..._array(..., ..., coda_array_ordering_fortran)
C    and keep the dimensions of your local variables the same (i.e.
C    use 'dimension ...(8,1024)').
C Method 2 requires some processing in the BEAT library and is thus
C slower than method 1. Furthermore, method 2 usually gives you the
C data in an inefficient form. If you use a loop like
C DO .., I = 1,8
C   DO .., J = 1,1024
C     ...
C then having a dimension(1024,8) variable gives you better performance
C than a dimension(8,1024) variable.
C For these reasons we decided to use method 1 in this example Fortran
C program.
C
      double precision pixel_array
      double precision lambda
      double precision fpn
      double precision leak
      double precision pet
      dimension pixel_array(1024,8)
      dimension lambda(1024,8)
      dimension fpn(1024,8)
      dimension leak(1024,8)
      dimension badpx(1024,8)
      character state_name(0:4)*14
      data state_name(0) / 'no measurement' /
      data state_name(1) / 'nadir' /
      data state_name(2) / 'limb' /
      data state_name(3) / 'occultation' /
      data state_name(4) / 'monitoring' /

      write(*,*) 'Name of the SCIAMACHY Level 1b file:'
      read(*,'(A1024)') filename

      result = coda_init()
      if (result .ne. 0) then
         call handle_coda_error()
      end if

      result = coda_set_option_perform_boundary_checks(0)

      result = coda_open(filename, pf)
      if (result .ne. 0) then
         call handle_coda_error()
      end if

      result = coda_get_product_class(pf, product_class)
      result = coda_get_product_type(pf, product_type)
      if (product_class(1:7) .ne. 'ENVISAT' .or. 
     &    product_type .ne. 'SCI_NL__1P') then
        write(stderr,*) 'Error: Not a SCIAMACHY Level 1b product'
        stop
      end if

      cursor = coda_cursor_new()

      result = coda_cursor_set_product(CURSOR, PF)

C     Read wavelengths of detector pixels
      result = coda_cursor_goto_record_field_by_name(cursor,
     &    'spectral_base')
      result = coda_cursor_goto_array_element_by_index(cursor, 0)
      result = coda_cursor_goto_record_field_by_name(cursor,
     &    'wvlen_det_pix')
      result = coda_cursor_read_double_array(cursor, lambda,
     &    coda_array_ordering_c)
      result = coda_cursor_goto_root(cursor)

C     Read fixed pattern noise data
      result = coda_cursor_goto_record_field_by_name(cursor,
     &    'leakage_constant')
      result = coda_cursor_goto_array_element_by_index(cursor, 0)
      result = coda_cursor_goto_record_field_by_name(cursor,
     &    'fpn_const')
      result = coda_cursor_read_double_array(cursor, fpn,
     &     coda_array_ordering_c)

C     Read leakage current data
      result = coda_cursor_goto_parent(cursor)
      result = coda_cursor_goto_record_field_by_name(cursor, 
     &    'leak_const')
      result = coda_cursor_read_double_array(cursor, leak,
     &    coda_array_ordering_c)
      result = coda_cursor_goto_root(cursor)

C     Read bad pixel map
      result = coda_cursor_goto_record_field_by_name(cursor,
     &    'ppg_etalon')
      result = coda_cursor_goto_array_element_by_index(cursor, 0)
      result = coda_cursor_goto_record_field_by_name(cursor,
     &    'bad_pix_mask')
      result = coda_cursor_read_int32_array(cursor, badpx,
     &    coda_array_ordering_c)

C     Initialize STATES cursor
      result = coda_cursor_goto_root(cursor)
      result = coda_cursor_goto_record_field_by_name(cursor, 'states')
      result = coda_cursor_get_num_elements(cursor, num_states)
      if (num_states .eq. 0) then
        write(STDERR,*) 'Product contains no data'
        stop
      end if
      result = coda_cursor_goto_first_array_element(cursor)

C     Initialize MDS cursors
      do 10, i = 1, 4
        mds_cursor(i) = coda_cursor_new()
        result = coda_cursor_set_product(mds_cursor(i), pf)
        result = coda_cursor_get_record_field_index_from_name(
     &      mds_cursor(i), state_name(i), field_index)
        result = coda_cursor_get_record_field_available_status(
     &      mds_cursor(i), field_index, available)
        if (available .ne. 0) then
          result = coda_cursor_goto_record_field_by_name(mds_cursor(i),
     &        state_name(i))
          result = coda_cursor_goto_first_array_element(mds_cursor(i))
        end if
10    continue

C     now walk the states
      do 50, stateNr = 1, num_states

C       Read mds_type, num_clus, and num_dsr
        result = coda_cursor_goto_record_field_by_name(cursor,
     &      'mds_type')
        result = coda_cursor_read_int32(cursor, mds_type)
        result = coda_cursor_goto_parent(cursor)
        result = coda_cursor_goto_record_field_by_name(cursor,
     &      'num_clus')
        result = coda_cursor_read_int32(cursor, num_clus)
        result = coda_cursor_goto_parent(cursor)
        result = coda_cursor_goto_record_field_by_name(cursor,
     &      'num_dsr')
        result = coda_cursor_read_int32(cursor, num_dsr)
        result = coda_cursor_goto_parent(cursor)

        write(*,*) 'Processing state ', stateNr, ' of ', num_states
        write(*,*) '  mds_type .....: ', mds_type, ' (' //
     &    state_name(mds_type)(1:length(state_name(mds_type))) // ')'
        write(*,*) '  num_clus .....: ', num_clus
        write(*,*) '  num_dsr ......: ', num_dsr

C       Just for safety we explicitly set num_dsr to 0 if mds_type = 0
C       If num_dsr > 0 we are dealing with a faulty product
        if (mds_type .eq. 0) then
          num_dsr = 0
        end if

C       traverse the MDSRs for this state
        do 60, dsrNr = 1, num_dsr

C         Initialize PIXEL_ARRAY with zeros
          do 65, chan_num = 1, 8
            do 70, pixelNr = 1, 1024
              pixel_array(pixelNr, chan_num) = 0D0
70          continue
65        continue

          clus_config_cursor = coda_cursor_duplicate(cursor)
          result = coda_cursor_goto_record_field_by_name(
     &        clus_config_cursor, 'clus_config')
          result = coda_cursor_goto_first_array_element(
     &        clus_config_cursor)

          clus_dat_cursor = coda_cursor_duplicate(mds_cursor(mds_type))
          result = coda_cursor_goto_record_field_by_name(
     &        clus_dat_cursor, 'clus_dat')
          result = coda_cursor_goto_first_array_element(clus_dat_cursor)

C         Traverse the clusters in this MDSR
          do 75, cluster = 1, num_clus

C           Read clus_config
            result = coda_cursor_goto_record_field_by_name(
     &          clus_config_cursor, 'chan_num')
            result = coda_cursor_read_int32(clus_config_cursor,
     &          chan_num)
            result = coda_cursor_goto_parent(clus_config_cursor)
            result = coda_cursor_goto_record_field_by_name(
     &          clus_config_cursor, 'start_pix')
            result = coda_cursor_read_int32(clus_config_cursor,
     &          start_pix)
            result = coda_cursor_goto_parent(clus_config_cursor)
            result = coda_cursor_goto_record_field_by_name(
     &          clus_config_cursor, 'clus_len')
            result = coda_cursor_read_int32(clus_config_cursor,
     &          clus_len)
            result = coda_cursor_goto_parent(clus_config_cursor)
            result = coda_cursor_goto_record_field_by_name(
     &          clus_config_cursor, 'pet')
            result = coda_cursor_read_double(clus_config_cursor, pet)
            result = coda_cursor_goto_parent(clus_config_cursor)
            result = coda_cursor_goto_record_field_by_name(
     &          clus_config_cursor, 'intgr_time')
            result = coda_cursor_read_int32(clus_config_cursor,
     &          intgr_time)
            result = coda_cursor_goto_parent(clus_config_cursor)
            result = coda_cursor_goto_record_field_by_name(
     &          clus_config_cursor, 'coadd_factor')
            result = coda_cursor_read_int32(clus_config_cursor,
     &          coadd_factor)
            result = coda_cursor_goto_parent(clus_config_cursor)
            result = coda_cursor_goto_record_field_by_name(
     &          clus_config_cursor, 'num_readouts')
            result = coda_cursor_read_int32(clus_config_cursor,
     &          num_readouts)
            result = coda_cursor_goto_parent(clus_config_cursor)
            result = coda_cursor_goto_record_field_by_name(
     &          clus_config_cursor, 'clus_data_type')
            result = coda_cursor_read_int32(clus_config_cursor,
     &          clus_data_type)
            result = coda_cursor_goto_parent(clus_config_cursor)

C           The integration time is not allways equal to intgr_time/16
C           since the integration time is sometimes equal to 1/32 which
C           can not be expressed with the intgr_time field. So always
C           use 'coadd_factor * pet' to calculate the integration time.
            it = coadd_factor * pet

C           Read clus_dat
            if (clus_data_type .eq. 1) then
              result = coda_cursor_goto_record_field_by_name(
     &            clus_dat_cursor, 'sig')
            else
              result = coda_cursor_goto_record_field_by_name(
     &            clus_dat_cursor, 'sigc')
            end if

            result = coda_cursor_goto_first_array_element(
     &          clus_dat_cursor)
            do  80, readoutNr = 1, num_readouts
              do 85, pixelNr = start_pix + 1, start_pix + clus_len

C               Read signal
                result = coda_cursor_goto_record_field_by_name(
     &              clus_dat_cursor, 'signal')
                result = coda_cursor_read_double(clus_dat_cursor,
     &              signal)
                pixel_array(pixelNr, chan_num) =
     &            pixel_array(pixelNr, chan_num) + signal

                result = coda_cursor_goto_parent(clus_dat_cursor)

                if (readoutNr .lt. num_readouts .or.
     &                pixelNr .lt. start_pix + clus_len) then
                  result = coda_cursor_goto_next_array_element(
     &                clus_dat_cursor)
                end if

85            continue
80          continue

C           Back to array
            result = coda_cursor_goto_parent(clus_dat_cursor)
C           Back to record
            result = coda_cursor_goto_parent(clus_dat_cursor)

            do 90, pixelNr = start_pix + 1, start_pix + clus_len

C             Take average
              pixel_array(pixelNr, chan_num) =
     &            pixel_array(pixelNr, chan_num) / num_readouts

C             Perform correction for fixed pattern noise and leakage
C             current
              pixel_array(pixelNr, chan_num) =
     &            pixel_array(pixelNr, chan_num) / it -
     &            fpn(pixelNr, chan_num) / pet - leak(pixelNr, chan_num)

90          continue

            if (cluster .lt. num_clus) then
              result = coda_cursor_goto_next_array_element(
     &            clus_config_cursor)
              result = coda_cursor_goto_next_array_element(
     &            clus_dat_cursor)
            end if

75        continue

C         Apply bad pixel map
          do 95, chan_num = 1, 8
            do 100, pixelNr = 1, 1024
              if (badpx(pixelNr, chan_num) .eq. 1) then
                pixel_array(pixelNr, chan_num) = coda_NaN()
              end if
100         continue
95        continue

          call coda_cursor_delete(clus_config_cursor)
          call coda_cursor_delete(clus_dat_cursor)

          result = coda_cursor_goto_next_array_element(
     &        mds_cursor(mds_type))

60      continue

        if (stateNr .lt. num_states) then
          result = coda_cursor_goto_next_array_element(cursor)
        end if

50    continue

      call coda_cursor_delete(cursor)
      do 150, i = 1, 4
        call coda_cursor_delete(mds_cursor(i))
150   continue

      result = coda_close(pf)

      call coda_done()

      end

      integer function length(string)
      character*(*) string
      integer i
      do 200, i = len(string), 1, -1
        if (string(i:i) .ne. ' ') then
          go to 210
        end if
200   continue
210   length = i
      end

      subroutine handle_coda_error

      implicit none

      include "coda.inc"

      integer err
      character*75 errstr

      err = coda_get_errno()
      call coda_errno_to_string(err, errstr)
      write(*,*) 'Error: ' // errstr
      stop

      end subroutine
