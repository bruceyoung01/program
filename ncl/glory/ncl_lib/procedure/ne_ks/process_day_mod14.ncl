; $ID: process_day_mod14.ncl V01 08/07/2012 20:33 BRUCE EXP$
;
;******************************************************************************
;  SUBROUTINE process_day_mod14 READS FILENAME, TOTAL # OF DAY, START INDEX, 
;  END INDEX, YEAR, MONTH, DATE, START TIME, END TIME, DAY NAME, AND THE # OF 
;  DAY FROM MODIS MOD14/MYD14 FILE NAME LIST DEPENDING ON THE INFO IN THE FILE 
;  NAMES.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir      (string) : MODIS FILE DIRECTORY                          [---]
;  (2 ) filelist (string) : FILE NAME LIST INCLUDING ALL THE FILE NAMES   [---]
;  (3 ) nday     (integer): TOTAL # OF DAY                                [---]
;  (4 ) filename (string) : ARRAY THAT SAVES ALL THE GRANULE FILENAMES    [---]
;  (5 ) startinx (integer): ARRAY THAT THE DIMENSION OF NDAY, INDEX WHERE 
;                           filename STARTS HAVE THE GRANULES NAMES FOR 
;                           THE DAY                                       [---]
;  (6 ) endinx   (integer): SAME AS STARTINX BUT FOR ENDS GRANULE NAMES 
;                           FOR THAT DAY                                  [---]
;  (7 ) year     (integer): YEAR OF MODIS DATA                            [---]
;  (8 ) mon      (integer): MONTH OF MODIS DATA                           [---]
;  (9 ) times    (string) : START TIME OF MODIS DATA FOR EACH DAY         [---]
;  (10) timee    (string) : END TIME OF MODIS DATA FOR EACH DAY           [---]
;  (11) dayname  (string) : ARRAY HAVE THE DIMENSIONS OF nday, SAVE NAMES 
;                           FOR EACH DAY                                  [---]
;  (12) daynum   (integer): ARRAY POINTING TO THE JULIAN DAY              [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/07/2012)
;  (2 ) MODIFIED FROM process_day_mod04.ncl. (10/08/2012)
;******************************************************************************

undef("process_day_mod14")
procedure process_day_mod14 \
          (dir       :string,   filelist  :string,    \ ; INPUT
           logic_leap:string,                         \ ; INPUT
           nday      :integer,                        \ ; OUTPUT
           startinx  :integer,  endinx    :integer,   \ ; OUTPUT
           year      :integer,  mon       :integer,   \ ; OUTPUT
           date      :integer,                        \ ; OUTPUT
           times     :string,   timee     :string,    \ ; OUTPUT
           dayname   :string,   daynum    :integer)     ; OUTPUT

begin

;  READ FILE NAME LIST
   filename = asciiread(dir + filelist, -1, "string")
   nfile    = dimsizes(filename)

;  DECODE DAY AND NIGHT
;  NON-LEAP YEAR
   if (logic_leap .eq. "nonleap") then
    days     = (/0, 31, 59, 90, 120, 151, 181, \
                 212, 243, 273, 304, 334, 365/)
;  LEAP YEAR
   else if (logic_leap .eq. "leap") then
    days     = (/0, 31, 60, 91, 121, 152, 182, \
                 213, 244, 274, 305, 335, 366/)
   end if
   end if

;  # OF MONTH PER YEAR
   nm       = 12
   ssinx    = 0
   di       = 0
   do i = 0, nfile-1
;  FROM FILE NAME TO JULIAN DAY
    onef    = filename(i)
    juliand = stringtoint(str_get_cols(onef, 11, 13))
    yearc   = stringtoint(str_get_cols(onef,  7, 10))
    if (i .lt. nfile-1)then
     nxf     = filename(i+1)
     nxjd    = stringtoint(str_get_cols(nxf, 11, 13))
    else if (i .eq. nfile-1)then
     nxf     = " "
     nxjd    = -9999
    end if
    end if

;  GET THE MONTH CORRECT
    do k = 0, nm-1
     if(juliand .ge. days(k)+1 .and. \
        juliand .lt. days(k+1)+1)then
      month = sprinti("%0.2i", (k+1))
      day   = sprinti("%0.2i", juliand-days(k))
      tmpday= (k+1)*100 + (juliand-days(k))
     end if
    end do

;  JUDGE IF ON THE SAME DAY
    if(juliand .ne. nxjd) then
     endinx(di)   = i
     startinx(di) = ssinx
     year(di)     = yearc
     mon(di)      = stringtoint(month)
     date(di)     = stringtoint(day)
     times(di)    = str_get_cols(filename(ssinx), 15, 18)
     timee(di)    = str_get_cols(filename(i), 15, 18)
     daynum(di)   = tmpday
     dayname(di)  = month + day + "JD" + \
                    str_get_cols(filename(ssinx), 11, 13)
     ssinx        = i + 1
     di           = di + 1
    end if
   end do
   nday = di

return
end
