;+
;
; (C) Cooperative Institute for Meteorological Satellite Studies, 1997
;
; NAME:
;       doy2date
;
; PURPOSE:
;       This function returns a date string corresponding to a given days 
;       of the year and year.
;
; CATEGORY:
;       Date_Time
;
; CALLING SEQUENCE:
;       result = doy2date( day_of_year, $        ; Input
;                          year, $               ; Input
;                          month   = month, $    ; Output keyword
;                          day     = day, $      ; Output keyword
;                          c_month = c_month )   ; Output keyword
;
; INPUTS:
;       day_of_year:    The day of year.
;       year:           The year, represented by up to 4 digits, for which
;                       the day of year has been specified.
;
; INPUT KEYWORD PARAMETERS:
;       None.
;	
; OUTPUTS:
;       The function returns a date string in the format DD-MMM-YYYY, e.g.
;       06-May-1998, 24-Jan-1997. If an error occurs, a NULL string is returned.
;
; OUTPUT KEYWORD PARAMETERS:
;       month:   Set this keyword to a named variable to return the number 
;                of the month (1 = January, ...., 12 = December).
;       day:     Set this keyword to a named variable to return the number 
;                of the day in the month.
;       c_month: Set this keyword to a named variable to return the month
;                as a string variable (January, ..., December).
;
; CALLS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       None known.
;
; RESTRICTIONS:
;       This software is Y2K compliant and as such expects the full year to
;       be specified. Passing the year as anything less than a 4 digit
;       positive number is valid, e.g. 94 represents the year 94 C.E., 
;       *NOT* 1994.
;
;       BCE years, i.e. year values < 0, are *NOT* accepted.
;
; EXAMPLE:
;       To print out the date as the returned result, or to create the date
;       as a string with format MM/DD/YY given the day of year 145 for 1994, 
;         type:
;
;         IDL> day_of_year = 145
;         IDL> year = 1994
;         IDL>PRINT, doy2date( day_of_year, year, month = month, day = day, c_month = c_month )
;         25-May-1994
;         IDL> date_string = STRING( month, FORMAT = '(i2)' ) + '/' + $
;         IDL> STRING( day, FORMAT = '(i2)' ) + '/' + $
;         IDL> STRMID( STRING( year, FORMAT = '(i4)' ), 2, 2 )
;         IDL> PRINT, date_string
;          5/25/94
;
;       Similarly for array data:
;
;         IDL> day_of_year = [ 145, 156, 366 ]
;         IDL> year = [ 1998, 1998, 1996 ]
;         IDL> c_date = doy2date( day_of_year, year, month = month, day = day, c_month = c_month)
;         IDL> PRINT, c_date
;         25-May-1998 05-Jun-1998 31-Dec-1996
;         IDL> PRINT, c_month, month, day
;         May June December
;                    5           6          12
;                   25           5          31
;
; MODIFICATION HISTORY:
;       Written by:     Paul van Delst, CIMSS/SSEC, 21-Feb-1997
;                       paul.vandelst@ssec.wisc.edu
;
;-

FUNCTION doy2date, day_of_year, $        ; Input
                   year, $               ; Input
                   month   = month, $    ; Output keyword
                   day     = day, $      ; Output keyword
                   c_month = c_month     ; Output keyword



;------------------------------------------------------------------------------
;                            -- RCS Id info --
;------------------------------------------------------------------------------

  rcs_ID = '$Id: doy2date.pro,v 1.6 2000/02/03 14:13:37 paulv Exp $'



;------------------------------------------------------------------------------
;                            -- Check inputs --
;------------------------------------------------------------------------------

; -------------------------------------
; Check for correct number of arguments
; -------------------------------------

  n_arguments = 2
  IF ( N_PARAMS() NE n_arguments ) THEN BEGIN
    MESSAGE, 'Incorrect number of arguments', /INFO
    RETURN, ''
  ENDIF


; ------------------------------
; Convert input to long integers
; ------------------------------

  l_day_of_year = LONG( day_of_year )
  l_year        = LONG( year )

  
; ---------------------------------
; Check for same number of elements
; ---------------------------------

  n_dates = N_ELEMENTS( l_day_of_year )
  IF ( n_dates NE N_ELEMENTS( l_year ) ) THEN BEGIN
    MESSAGE, 'DAY_OF_YEAR and YEAR inputs must be same size.', /INFO
    RETURN, ''
  ENDIF


; ---------
; Check day
; ---------

  index = WHERE( l_day_of_year LE 0, count )
  IF ( count GT 0 ) THEN BEGIN
    MESSAGE, 'Invalid day of year, < 1, specified', /INFO
    RETURN, ''
  ENDIF

  index = WHERE( l_day_of_year GT 366, count )
  IF ( count GT 0 ) THEN BEGIN
    MESSAGE, 'Invalid day of year, > 366, specified', /INFO
    RETURN, ''
  ENDIF
             

; ----------
; Check year
; ----------

  index = WHERE( l_year LE 0, count )
  IF ( count GT 0 ) THEN BEGIN
    MESSAGE, 'Invalid year, < 1, specified', /INFO
    RETURN, ''
  ENDIF

  index = WHERE( l_year GT 9999, count )
  IF ( count GT 0 ) THEN BEGIN
    MESSAGE, 'Function not Y10K compliant!', /INFO
    RETURN, ''
  ENDIF



;------------------------------------------------------------------------------
;        -- Set day of year array based on if year is a leap year --
;------------------------------------------------------------------------------

; ------------------------------
; Define day-of-(leap)year array
; ------------------------------

  day_of_year_array = [ 31L, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365 ]
  day_of_year_array = REBIN( day_of_year_array, 12, n_dates )


; --------------------
; Is this a leap year?
; --------------------

  index_leap = WHERE( ( ( l_year MOD 4 EQ 0 ) AND ( l_year MOD 100 NE 0 ) ) OR $
                      ( l_year MOD 400 EQ 0 ), count_leap )

; -- No.
  IF ( count_leap GT 0 ) THEN BEGIN
    day_of_year_array[ 1 : *, index_leap ] = day_of_year_array[ 1 : *, index_leap ] + 1
  ENDIF


; ----------------------------------------------------------------
; Here is another check to make sure that if day 366 was specified
; it was actually for a leap year
; ----------------------------------------------------------------

  index = WHERE( l_day_of_year EQ 366, count )
  IF ( count_leap EQ 0 AND $   ; Not a leap year and....
       count NE 0 ) $          ; day 366 specified 
  THEN BEGIN
    MESSAGE, '366th day specified for non-leap year!', /INFO
    RETURN, ''
  ENDIF



;------------------------------------------------------------------------------
;                        -- Determine the month --
;------------------------------------------------------------------------------

; -------------------------
; Define string month array
; -------------------------

  c_month_array = [ 'January', 'February', 'March', 'April', 'May', 'June', $
                    'July', 'August', 'September', 'October', 'November', 'December' ]


; --------------------
; Create output arrays
; --------------------

  month   = LONARR( n_dates )
  c_month = STRARR( n_dates )


; ----------
; Fill them!
; ----------

  FOR i = 0, n_dates - 1 DO BEGIN
    index        = WHERE( day_of_year_array[ *, i ] LT l_day_of_year[ i ], count )
    month[ i ]   = count + 1
    c_month[ i ] = c_month_array[ month[ i ] - 1 ]
  ENDFOR



;------------------------------------------------------------------------------
;                     -- Determine the day of month --
;------------------------------------------------------------------------------

; -----------------------------
; Create the day of month array
; -----------------------------

  day   = LONARR( n_dates )


; --------------
; Fill the array
; --------------

; -- For January
  index = WHERE( month EQ 1, count )
  IF ( count GT 0 ) THEN BEGIN
    day[ index ] = l_day_of_year
  ENDIF

; -- Every other month
  index = WHERE( month GT 1, count )
  IF ( count GT 0 ) THEN BEGIN
    day[ index ] = l_day_of_year - REFORM( day_of_year_array[ month - 2, index ] )
  ENDIF


;------------------------------------------------------------------------------
;  -- Construct the return string. Have to futz a bit with the conversion --
;  -- as IDL doesn't let you explicit format string arrays of length more --
;  -- than 1024 elements. Sheesh!                                         --
;------------------------------------------------------------------------------

  max_string_length   = 1024L


; --------------------------------------------------
; If the string array is larger than the maximum....
; --------------------------------------------------

  IF ( n_dates GT max_string_length ) THEN BEGIN

;   -- Create the date string array
    date_string = STRARR( n_dates )

;   -- Determine the number of 1024 length blocks to convert
    n_conversion_blocks = n_dates / max_string_length
    n_conversion_number = MAKE_ARRAY( n_conversion_blocks, VALUE = max_string_length )

;   -- Determine the remainder 
    n_remainder = n_dates MOD max_string_length
    IF ( n_remainder GT 0 ) THEN BEGIN
      n_conversion_blocks = n_conversion_blocks + 1
      n_conversion_number = [ n_conversion_number, n_remainder ]
    ENDIF

;   -- Loop over the conversion blocks
    FOR i = 0L, n_conversion_blocks - 1 DO BEGIN

      begin_index = i * max_string_length
      end_index   = begin_index + n_conversion_number[ i ] - 1

      date_string[ begin_index : end_index ] = $
        STRING( day[ begin_index : end_index ], FORMAT = '(i2.2)' ) + '-' + $
        STRMID( c_month[ begin_index : end_index ], 0, 3 ) + '-' + $
        STRCOMPRESS( STRING( l_year[ begin_index : end_index ], FORMAT = '(i4)' ), /REMOVE_ALL )

    ENDFOR


; --------------------------------------------------
; If the string array is smaller than the amximum...
; --------------------------------------------------

  ENDIF ELSE BEGIN

    date_string = STRING( day, FORMAT = '(i2.2)' ) + '-' + $
                  STRMID( c_month, 0, 3 ) + '-' + $
                  STRCOMPRESS( STRING( l_year, FORMAT = '(i4)' ), /REMOVE_ALL )

  ENDELSE



;------------------------------------------------------------------------------
;                                   -- Done --
;------------------------------------------------------------------------------

  RETURN, date_string

END

;==============================================================================
; CVS/RCS keyword modification history
;
; $Log: doy2date.pro,v $
; Revision 1.6  2000/02/03 14:13:37  paulv
; Corrected bug in leap-year detection.
;
; Revision 1.5  1999/09/08 22:35:36  paulv
; - Removed ASSERTION function calls on errors. Replaced with IF statements
;   and NULL string return to calling function.
; - Updated header documentation.
;
; Revision 1.4  1998/12/10 18:53:31  paulv
; Added check to see if the array length passed is greater than the maximum
;   IDL allows (1024). If it is, then the date array is converted to a string
;   in blocks of 1024 elements to prevent a) the array being truncated at
;   1024 elements and b) the output of the annoying message telling the user
;   that the array has been truncated at 1024 elements. A totally ridiculous
;   limit on IDL string array processing.
;
; Revision 1.3  1998/08/27 19:15:55  paulv
; Revised code to accept array input arguments.
;
; Revision 1.2  1998/05/06 18:32:20  paulv
; Documentation update.
;
; Revision 1.1  1998/05/06 18:28:49  paulv
; Initial revision
;
;==============================================================================

