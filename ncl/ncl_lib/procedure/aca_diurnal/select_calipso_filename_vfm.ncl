;  $ID: select_calipso_filename_vfm.ncl V01 11/21/2015 11:21 ZHIFENG YANG EXP$
;
;******************************************************************************
;  PROGRAM select_calipso_filename_vfm SELECTS CALIPSO FILE NAMES FROM FILE 
;  LIST BASED ON YEAR, MONTH, AND DAY.
;  CALIPSO FILE NAME EXAMPLES ARE
;  CAL_LID_L2_VFM-ValStage1-V3-30.2014-12-31T01-56-29ZN.hdf
;  CAL_LID_L2_VFM-ValStage1-V3-30.2014-12-31T02-42-49ZD.hdf
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir             (string):CALIPSO DATA DIRECTORY                   [   ]
;  (2 ) filelist        (string):A FILE CONTAINING ALL THE CALIPSO FILENAMES[ ]
;  (3 ) year           (integer):YEAR NEEDED                              [   ]
;  (4 ) month          (integer):MONTH NEEDED                             [   ]
;  (5 ) day            (integer):DAY NEEDED                               [   ]
;  (6 ) sday_or_night   (string):DAY TIME OR NIGHT FOR FILENAME NEEDED    [   ]
;  (7 ) logic_filename (logical):CHECK WHETHER FILENAMES EXIST            [   ]
;  (8 ) sfilename       (string):SELECTED FILENAMES                       [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY ZHIFENG YANG. (11/21/2015)
;******************************************************************************
undef("select_calipso_filename_vfm")
procedure select_calipso_filename_vfm \
          (dir            :string,  filelist     :string,   \ ;INPUT
           year           :integer, month        :integer,  \ ;INPUT
           day            :integer, sday_or_night:string,   \ ;INPUT
           logic_filename :logical, sfilename    :string)     ;OUTPUT

begin

;  CONVERT YEAR TO STRING
   syear     = sprinti("%0.4i", year)

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
