;  $ID: match_modis_mod03_mod04_mod06_filename_yearmonthday.ncl V01 07/22/2015 14:33 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE match_modis_mod03_mod04_mod06_filename_yearmonthday.ncl MATCHES 
;  MODIS FILENAMES OF MOD03/MYD03, MOD04_L2/MYD04_L2, AND MOD06_L2/MYD04_L2, 
;  TO MAKE SURE THE FILENAMES WITH SAME YEAR, JULIAN DAY, HOUR, AND MIN ARE 
;  SELECTED.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) year              (scalar)   :YEAR OF MODIS DATA                  [   ]
;  (2 ) month             (scalar)   :MONTH OF MODIS DATA                 [   ]
;  (3 ) day               (scalar)   :DAY OF MODIS DATA                   [   ]
;  (4 ) m3dir             (a string) :MOD03/MYD03 DATA DIRECTORY          [   ]
;  (5 ) m3filelist        (a string) :MOD03/MYD03 FILE NAME LIST          [   ]
;  (6 ) m4dir             (a string) :MOD04_L2/MYD04_L2 DATA DIRECTORY    [   ]
;  (7 ) m4filelist        (a string) :MOD04_L2/MYD04_L2 FILE NAME LIST    [   ]
;  (8 ) m6dir             (a string) :MOD06_L2/MYD06_L2 DATA DIRECTORY    [   ]
;  (9 ) m6filelist        (a string) :MOD06_L2/MYD06_L2 FILE NAME LIST    [   ]
;  (10) ssm3filename      (1-D)      :SELECTED MATCHING MOD03/MYD03 FILE NAME
;  (11) ssm4filename      (1-D)      :SELECTED MATCHING MOD04_L2/MYD04_L2 FILE NAME
;  (12) ssm6filename      (1-D)      :SELECTED MATCHING MOD06_L2/MYD06_L2 FILE NAME
;  (13) nssmfilename_real (scalar)   :REAL NUMBER OF SELECTED MATCHING FILE[  ]
;  (14) logic_ssmfilename (a logical):LOGICAL FOR FILE EXISTANCE          [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/22/2015)
;******************************************************************************
undef("match_modis_mod03_mod04_mod06_filename_yearmonthday")
procedure match_modis_mod03_mod04_mod06_filename_yearmonthday \
          (year             :integer, month             :integer,\;INPUT
           day              :integer,                            \;INPUT
           m3dir            :string,  m3filelist        :string, \;INPUT
           m4dir            :string,  m4filelist        :string, \;INPUT
           m6dir            :string,  m6filelist        :string, \;INPUT
           ssm3filename     :string,  ssm4filename      :string, \;OUTPUT
           ssm6filename     :string,  nssmfilename_real :integer,\;OUTPUT
           logic_ssmfilename:logical)                             ;OUTPUT

begin
   syear       = sprinti("%4.4i", year)
   smonth      = sprinti("%2.2i", month)
   sday        = sprinti("%2.2i", day)

;  MOD03 FILE INFO
   m3filename  = asciiread(m3dir + syear + "/" + m3filelist, -1, "string")
   nm3filename = dimsizes(m3filename)
;  MOD04_L2 FILE INFO
   m4filename  = asciiread(m4dir + syear + "/" + m4filelist, -1, "string")
   nm4filename = dimsizes(m4filename)
;  MOD06_L2 FILE INFO
   m6filename  = asciiread(m6dir + syear + "/" + m6filelist, -1, "string")
   nm6filename = dimsizes(m6filename)

;  EXTRACT YEAR, JULIAN DAY, HOUR, AND MINUTE FROM MOD03/MYD03 FILENAMES
   m3year      = str_get_cols(m3filename, 7,  10)
   m3julian    = str_get_cols(m3filename, 11, 13)
   im3year     = stringtoint(m3year)
   im3julian   = stringtoint(m3julian)
;  CONVERT JULIAN DAY TO MONTH AND DAY
   m3md        = monthday(im3year, im3julian)
   sm3md       = sprinti("%4.4i", m3md)
   m3month     = str_get_cols(sm3md, -4, -3)
   m3day       = str_get_cols(sm3md, -2, -1)
   m3hour      = str_get_cols(m3filename, 15, 16)
   m3min       = str_get_cols(m3filename, 17, 18)
;  EXTRACT YEAR, JULIAN DAY, HOUR, AND MINUTE FROM MOD04_L2/MYD04_L2 FILENAMES
   m4year      = str_get_cols(m4filename, 10, 13)
   m4julian    = str_get_cols(m4filename, 14, 16)
   im4year     = stringtoint(m4year)
   im4julian   = stringtoint(m4julian)
;  CONVERT JULIAN DAY TO MONTH AND DAY
   m4md        = monthday(im4year, im4julian)
   sm4md       = sprinti("%4.4i", m4md)
   m4month     = str_get_cols(sm4md, -4, -3)
   m4day       = str_get_cols(sm4md, -2, -1)
   m4hour      = str_get_cols(m4filename, 18, 19)
   m4min       = str_get_cols(m4filename, 20, 21)
;  EXTRACT YEAR, JULIAN DAY, HOUR, AND MINUTE FROM MOD06_L2/MYD06_L2 FILENAMES
   m6year      = str_get_cols(m6filename, 10, 13)
   m6julian    = str_get_cols(m6filename, 14, 16)
   im6year     = stringtoint(m6year)
   im6julian   = stringtoint(m6julian)
;  CONVERT JULIAN DAY TO MONTH AND DAY
   m6md        = monthday(im6year, im6julian)
   sm6md       = sprinti("%4.4i", m6md)
   m6month     = str_get_cols(sm6md, -4, -3)
   m6day       = str_get_cols(sm6md, -2, -1)
   m6hour      = str_get_cols(m6filename, 18, 19)
   m6min       = str_get_cols(m6filename, 20, 21)

;  DO nm3filename LOOP FIND INDICES WITH MOD03/MYD03, MOD04_L2/MYD04_L2, 
;  AND MOD06_L2/MYD06_L2 MATCHING
   iloop = 0
   do im3filename = 0, nm3filename-1
      index4 = ind(m4year   .eq. syear                 .and. \
                   m4year   .eq. m3year(im3filename)   .and. \
                   m4julian .eq. m3julian(im3filename) .and. \
                   m4month  .eq. smonth                .and. \
                   m4day    .eq. sday                  .and. \
                   m4hour   .eq. m3hour(im3filename)   .and. \
                   m4min    .eq. m3min(im3filename))
      index6 = ind(m6year   .eq. syear                 .and. \
                   m6year   .eq. m3year(im3filename)   .and. \
                   m6julian .eq. m3julian(im3filename) .and. \
                   m6month  .eq. smonth                .and. \
                   m6day    .eq. sday                  .and. \
                   m6hour   .eq. m3hour(im3filename)   .and. \
                   m6min    .eq. m3min(im3filename))

      if (.not.all(ismissing(index4)) .and. \
          .not.all(ismissing(index6))) then
         nindex4 = dimsizes(index4)
         nindex6 = dimsizes(index6)
         if (nindex4 .eq. 1 .and. \
             nindex6 .eq. 1) then
            ssm3filename(iloop) = m3filename(im3filename)
            ssm4filename(iloop) = m4filename(index4)
            ssm6filename(iloop) = m6filename(index6)
            iloop = iloop + 1
         else if (nindex4 .lt. 1) then
            print("FIND MORE THAN ONE FILE MATCHES, PLEASE CHECK MOD04_L2/MYD04_L2 FILE REPETITION!!!")
         else if (nindex6 .lt. 1) then
            print("FIND MORE THAN ONE FILE MATCHES, PLEASE CHECK MOD06_L2/MYD06_L2 FILE REPETITION!!!")
         end if
         end if
         end if
      end if
      delete([/index4, index6/])
   end do ;im3filename
   nssmfilename_real = iloop
   if (nssmfilename_real .ge. 1) then
      logic_ssmfilename = False
   end if
end
