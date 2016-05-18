      program showheaders

      implicit none

      include "coda.inc"

      character*1024 filename
      character*32 product_class
C use 'integer*8 pf' for 64-bit
      integer pf
C use 'integer*8 cursor' for 64-bit
      integer cursor
C use 'integer*8 num_dsd' for 64-bit
      integer num_dsd
      integer result
      integer i

      write(*,*) 'Name of the ENVISAT product file:'
      read(*,'(A1024)') filename

      result = coda_init()
      if (result .ne. 0) then
        call handle_coda_error()
      end if

C     Disable unit conversions.
C     We want to provide the header data in raw form.
      result = coda_set_option_perform_conversions(0)

      result = coda_open(filename, pf)
      if (result .ne. 0) then
        call handle_coda_error()
      end if

      result = coda_get_product_class(pf, product_class)
      if (result .ne. 0) then
        call handle_coda_error()
      end if
      if (product_class(1:7) .ne. 'ENVISAT') then
        write(*,*) 'Error: Not an ENVISAT product file'
        stop
      end if

      cursor = coda_cursor_new()

      result = coda_cursor_set_product(cursor, pf)
      if (result .ne. 0) then
        call handle_coda_error()
      end if

      write(*,*) '  MPH :'
      result = coda_cursor_goto_record_field_by_name(cursor, 'mph')
      if (result .ne. 0) then
        call handle_coda_error()
      end if
      call print_record(cursor)
      result = coda_cursor_goto_parent(cursor)

      write(*,*) '  SPH : '
      result = coda_cursor_goto_record_field_by_name(cursor, 'sph')
      if (result .ne. 0) then
        call handle_coda_error()
      end if
      call print_record(cursor)
      result = coda_cursor_goto_parent(cursor)

      result = coda_cursor_goto_record_field_by_name(cursor, 'dsd')
      if (result .ne. 0) then
        call handle_coda_error()
      end if
      result = coda_cursor_get_num_elements(cursor, num_dsd)
      if (result .ne. 0) then
        call handle_coda_error()
      end if
      if (num_dsd .gt. 0) then
        result = coda_cursor_goto_first_array_element(cursor)
        if (result .ne. 0) then
          call handle_coda_error()
        end if
        do 10, i = 1, num_dsd
          write(*,'(1X,A,I2.2,A)') '  DSD(', i, ') :'
          call print_record(cursor)
          if (i .lt. num_dsd) then
            result = coda_cursor_goto_next_array_element(cursor)
          end if
10      continue
      end if
      result = coda_cursor_goto_parent(cursor)

      call coda_cursor_delete(cursor)

      result = coda_close(pf)

      call coda_done()

      end program


      subroutine print_record(cursor)

      implicit none

      external length
      integer length

      include "coda.inc"

      character*32 field_name
C use 'integer*8 cursor' for 64-bit
      integer cursor
C use 'integer*8 num_fields' for 64-bit
      integer num_fields
C use 'integer*8 record_type' for 64-bit
      integer record_type
      integer hidden
      integer result
      integer i

      result = coda_cursor_get_num_elements(cursor, num_fields)
      if (result .ne. 0) then
        call handle_coda_error()
      end if
      if (num_fields .gt. 0) then
        result = coda_cursor_get_type(cursor, record_type)
        result = coda_cursor_goto_first_record_field(cursor)
        if (result .ne. 0) then
          call handle_coda_error()
        end if
        do 50, i = 1, num_fields
C         We don't print fields that are hidden, like the first MPH 
C         field (with value 'PRODUCT=')
          result = coda_type_get_record_field_hidden_status(record_type,
     &        i - 1, hidden)
          if (hidden .eq. 0) then
            result = coda_type_get_record_field_name(record_type, i - 1,
     &        field_name)
            write(*,'(1X,A32,A,$)') field_name(1:length(field_name)),
     &        ' : '
            call print_data(cursor)
            write(*,*) ''
          end if
          if (i .lt. num_fields) then
            result = coda_cursor_goto_next_record_field(cursor)
          end if
50      continue
        result = coda_cursor_goto_parent(cursor)

      end if

      end subroutine


      subroutine print_data(cursor)

      implicit none

      external length
      integer length

      include "coda.inc"

      character*32 type_name
      character*27 str
      double precision time
C use 'integer*8 cursor' for 64-bit
      integer cursor
      integer type_class
      integer special_type
C use 'integer*8 num_elements' for 64-bit
      integer num_elements
      integer i
      integer result

      result = coda_cursor_get_type_class(cursor, type_class)
      if (type_class .eq. coda_array_class) then
        result = coda_cursor_get_num_elements(cursor, num_elements)
        if (result .ne. 0) then
          call handle_coda_error()
        end if
        if (num_elements .gt. 0) then
          write(*,'(A,$)') '['
          result = coda_cursor_goto_first_array_element(cursor)
          if (result .ne. 0) then
            call handle_coda_error()
          end if
          do 100, i = 1, num_elements
            call print_basic_type(cursor)
            if (i .lt. num_elements) then
              write(*,'(A2,$)') ', '
              result = coda_cursor_goto_next_array_element(cursor)
            end if
100       continue
          write(*,'(A,$)') ']'
          result = coda_cursor_goto_parent(cursor)
        end if
      else if (type_class .eq. coda_special_class) then
        result = coda_cursor_get_special_type(cursor, special_type)
        if (special_type .eq. coda_special_time) then
          result = coda_cursor_read_double(cursor, time)
          if (result .ne. 0) then
            call handle_coda_error()
          end if
          result = coda_time_to_string(time, str)
          write(*,'(A,$)') str
        else
          call coda_type_get_special_type_name(special_type, type_name)
          write(*,'(A,$)') '*** Unexpected special type (' //
     &        type_name(1:length(type_name)) // ') ***'
        end if
      else
        call print_basic_type(cursor)
      end if

      end subroutine


      subroutine print_basic_type(cursor)

      implicit none

      external length
      integer length

      include "coda.inc"

      character*32 type_name
C use 'integer*8 cursor' for 64-bit
      integer cursor
      integer read_type
      character chardata
      integer*4 integerdata
      double precision floatdata
      character*1024 stringdata
      integer result

      result = coda_cursor_get_read_type(cursor, read_type)
      if (read_type .eq. coda_native_type_int8 .or.
     &    read_type .eq. coda_native_type_uint8 .or.
     &    read_type .eq. coda_native_type_int16 .or.
     &    read_type .eq. coda_native_type_uint16 .or.
     &    read_type .eq. coda_native_type_int32) then
        result = coda_cursor_read_int32(cursor, integerdata)
        if (result .ne. 0) then
          call handle_coda_error()
        end if
        write(*,'(I14,$)') integerdata
      else if (read_type .eq. coda_native_type_uint32 .or.
     &         read_type .eq. coda_native_type_int64 .or.
     &         read_type .eq. coda_native_type_uint64) then
C       We read an unsigned 32 bit integer and 64 bit integer data
C       as a 'double precision' because by default we don't have
C       unsigned 32 bit or 64 bit types in Fortran
        result = coda_cursor_read_double(cursor, floatdata)
        if (result .ne. 0) then
          call handle_coda_error()
        end if
        write(*,'(F15.0,$)') floatdata
      else if (read_type .eq. coda_native_type_float .or.
     &         read_type .eq. coda_native_type_double) then
        result = coda_cursor_read_double(cursor, floatdata)
        if (result .ne. 0) then
          call handle_coda_error()
        end if
        write(*,'(F15.0,$)') floatdata
      else if (read_type .eq. coda_native_type_char) then
        result = coda_cursor_read_char(cursor, chardata)
        if (result .ne. 0) then
          call handle_coda_error()
        end if
        write(*,'(A14,$)') chardata
      else if (read_type .eq. coda_native_type_string) then
        stringdata = ''
        result = coda_cursor_read_string(cursor, stringdata)
        if (result .ne. 0) then
          call handle_coda_error()
        end if
        write(*,'(A,$)') stringdata(1:length(stringdata))
      else
        call coda_type_get_native_type_name(read_type, type_name)
        write(*,'(A,$)') '*** Unexpected read type (' //
     &      type_name(1:length(type_name)) // ') ***'
      end if

      end subroutine


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
