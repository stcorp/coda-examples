      program absorbit

      implicit none

      include "coda.inc"

      character*1024 filename
      character*32 product_class
C use 'integer*8 pf' for 64-bit
      integer pf
C use 'integer*8 cursor' for 64-bit
      integer cursor
      integer*4 abs_orbit
      integer result

      write(*,*) 'Name of the product file:'
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

      cursor = coda_cursor_new()

      result = coda_cursor_set_product(cursor, pf)
      if (result .ne. 0) then
        call handle_coda_error()
      end if

      result = coda_cursor_goto_record_field_by_name(cursor, 'mph')
      if (result .ne. 0) then
        call handle_coda_error()
      end if

      result = coda_cursor_goto_record_field_by_name(cursor,
     &    'abs_orbit')
      if (result .ne. 0) then
        call handle_coda_error()
      end if

      result = coda_cursor_read_int32(cursor, abs_orbit)
      if (result .ne. 0) then
        call handle_coda_error()
      end if

      write(*,*) 'absolute orbit: ', abs_orbit

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
