;  $ID: select_calipso_filename.ncl V01 06/16/2015 09:13 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM select_calipso_filename SELECTS CALIPSO FILE NAMES FROM FILE 
;  LIST BASED ON YEAR, MONTH, AND DAY.
;  CALIPSO FILE NAME EXAMPLES ARE
;  CAL_LID_L2_05kmAPro-Prov-V3-01.2006-12-31T23-30-19ZD.hdf
;  CAL_LID_L2_05kmALay-Prov-V3-01.2007-07-02T04-56-05ZN.hdf
;  CAL_LID_L2_05kmCLay-Prov-V3-01.2007-07-01T19-02-49ZN.hdf
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir             (string):CALIPSO DATA DIRECTORY                   [   ]
;  (2 ) filelist        (string):A FILE CONTAINING ALL THE CALIPSO FILENMES[  ]
;  (3 ) year           (integer):YEAR NEEDED                              [   ]
;  (4 ) month          (integer):MONTH NEEDED                             [   ]
;  (5 ) day            (integer):DAY NEEDED                               [   ]
;  (6 ) day_or_night   (integer):DAY TIME OR NIGHT FOR FILENAME NEEDED    [   ]
;  (7 ) logic_filename (logical):CHECK WHETHER FILENAMES EXIST            [   ]
;  (8 ) sfilename       (string):SELECTED FILENAMES                       [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/16/2015)
;******************************************************************************
undef("select_calipso_filename")
procedure select_calipso_filename \
          (dir            :string,  filelist    :string,   \ ;INPUT
           year           :integer, month       :integer,  \ ;INPUT
           day            :integer, day_or_night:integer,  \ ;INPUT
           logic_filename :logical, sfilename   :string)     ;OUTPUT

begin

;  CONVERT YEAR TO STRING
   syear     = sprinti("%0.4i", year)

;  DAY OR NIGHT
   if (day_or_night .eq. 0) then
      sday_or_night = "D"
   else if (day_or_night .eq. 1) then
      sday_or_night = "N"
   end if
   end if

;  READ FILE NAMES FROM FILE LIST
   filename  = asciiread(dir + syear + "/" + filelist, -1, "string")
   nfilename = dimsizes(filename)

;  GET YEAR, MONTH, AND DAY INFO FROM FILE NAME LIST
   cyear         = stringtoint(str_get_cols(filename, 31, 34))
   cmonth        = stringtoint(str_get_cols(filename, 36, 37))
   cday          = stringtoint(str_get_cols(filename, 39, 40))
   cday_or_night = str_get_cols(filename, -5, -5)

;  SELECT FILE NAMES DEPENDING ON GIVEN YEAR, MONTH, AND DAY
   index = ind(cyear         .eq. year  .and. \
               cmonth        .eq. month .and. \
               cday          .eq. day   .and. \
               cday_or_night .eq. sday_or_night)
;  CHECK IF EXPECTED FILE NAMES ARE MISSING OR NOT
   if (all(ismissing(index))) then
      print("-----------------------------------------------------------------")
      print("CALIOP FILE NAME IS MISSING")
      logic_filename = False
   else
      nindex    = num(.not.ismissing(index))
      sfilename(0:nindex-1) = filename(index(0:nindex-1))
      logic_filename = True
   end if
return
end
