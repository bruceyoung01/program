; $ID: process_day_wrf.ncl V01 08/12/2012 22:03 BRUCE EXP$
;
;******************************************************************************
;  SUBROUTINE process_day_wrf READS WRF FILE NAME LIST TO GET FILENAMES, TOTAL 
;  # OF DAY, START INDEX, END INDEX, YEAR, MONTH, DATE, START TIME, END TIME, 
;  DAY NAME, AND THE # OF DAY.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/12/2012)
;******************************************************************************

undef("process_day_wrf")
procedure process_day_wrf \
          (dir        :string,  filelist    :string,   \ ; INPUT
           logic_leap :string,                         \ ; INPUT
           nday       :integer,                        \ ; OUTPUT
           startinx   :integer, endinx      :integer,  \ ; OUTPUT
           year       :integer, mon         :integer,  \ ; OUTPUT
           date       :integer,                        \ ; OUTPUT
           times      :string,  timee       :string,   \ ; OUTPUT
           dayname    :string,  daynum      :integer)    ; OUTPUT

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
    onef     = filename(i)
    wyears   = str_get_cols(onef, 11, 14)
    wmonths  = str_get_cols(onef, 16, 17)
    wdays    = str_get_cols(onef, 19, 20)
    yyyymmdds= wyears + wmonths + wdays
    yyyymmdd = stringtoint(yyyymmdds)
    yyyyddd  = yyyymmdd_to_yyyyddd(yyyymmdd)
    juliand  = stringtoint(str_get_cols(int2string(yyyyddd), 3, 5))
    if (i .lt. nfile-1)then
     nxf      = filename(i+1)
     nxyears  = str_get_cols(nxf, 11, 14)
     nxmonths = str_get_cols(nxf, 16, 17)
     nxdays   = str_get_cols(nxf, 19, 20)
     nxyyyymmdds= nxyears + nxmonths + nxdays
     nxyyyymmdd = stringtoint(nxyyyymmdds)
     nxyyyyddd  = yyyymmdd_to_yyyyddd(nxyyyymmdd)
     nxjd       = stringtoint(str_get_cols(int2string(nxyyyyddd), 3, 5))
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
     year(di)     = stringtoint(wyears)
     mon(di)      = stringtoint(month)
     date(di)     = stringtoint(day)
     times(di)    = str_get_cols(filename(ssinx), 18, 21)
     timee(di)    = str_get_cols(filename(i), 18, 21)
     daynum(di)   = tmpday
     dayname(di)  = month + day + "JD" + \
                    str_get_cols(filename(ssinx), 14, 16)
     ssinx        = i + 1
     di           = di + 1
    end if
   end do
   nday = di

return
end
