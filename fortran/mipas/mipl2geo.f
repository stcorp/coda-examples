      program mipl2geo

      implicit none

      include "coda.inc"

      character*1024 filename
      character*32 product_class
      character*32 product_type
      double precision latitude
      double precision longitude
C use 'integer*8 pf' for 64-bit
      integer pf
C use 'integer*8 cursor' for 64-bit
      integer cursor
C use 'integer*8 num_dsr' for 64-bit
      integer num_dsr
      integer result
      integer i

      write(*,*) 'Name of the MIPAS Level 2 file:'
      read(*,'(A1024)') filename

      result = coda_init()
      if (result .ne. 0) then
        call handle_coda_error()
      end if

      result = coda_open(filename, pf)
      if (result .ne. 0) then
        call handle_coda_error()
      end if

      result = coda_get_product_class(pf, product_class)
      if (product_class(1:7) .ne. 'ENVISAT') then
        write(*,*) 'Error: file is not an ENVISAT file'
        stop
      end if

      result = coda_get_product_type(pf, product_type)
      if (product_type .ne. 'MIP_NL__2P' .and.
     &    product_type .ne. 'MIP_NLE_2P') then
        write(*,*) 'Error: file is not a MIPAS Level 2 file'
        stop
      end if

      cursor = coda_cursor_new()

      result = coda_cursor_set_product(cursor, pf)
      if (result .ne. 0) then
        call handle_coda_error()
      end if

      result = coda_cursor_goto_record_field_by_name(cursor,
     &    'scan_geolocation_ads')
      if (result .ne. 0) then
        call handle_coda_error()
      end if

      result = coda_cursor_get_num_elements(cursor, num_dsr)
      if (result .ne. 0) then
        call handle_coda_error()
      end if

      if (num_dsr .gt. 0) then
        result = coda_cursor_goto_first_array_element(cursor)
        do 15, i = 1, num_dsr
          result = coda_cursor_goto_record_field_by_name(cursor,
     &        'loc_mid')
          result = coda_cursor_goto_record_field_by_name(cursor,
     &        'latitude')
          result = coda_cursor_read_double(cursor, latitude)
          result = coda_cursor_goto_next_record_field(cursor)
          result = coda_cursor_read_double(cursor, longitude)
          write(*,*) 'latitude : ', latitude, '  longitude : ',
     &        longitude
          result = coda_cursor_goto_parent(cursor)
          result = coda_cursor_goto_parent(cursor)
          if (i .lt. num_dsr) then
            result = coda_cursor_goto_next_array_element(cursor)
          end if
15      continue
      end if

      call coda_cursor_delete(cursor)

      result = coda_close(pf)

      call coda_done()

      end program


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
