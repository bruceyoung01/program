; $ID: filename_start_end.ncl V01 05/09/2012 20:18 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE filename_start_end READS SATELLITE FILE NAMES AND JUDGE THE YEAR,
;  MONTH, DAY, HOUR OF START AND END.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir         (string)  : SATELLITE FILE DIRECTORY                  [---]
;  (2 ) sfile       (string)  : SATELLITE FILE NAME LIST                  [---]
;  (3 ) start_year  (integer) :START YEAR OF DATA                         [---]
;  (4 ) end_year    (integer) :END YEAR OF DATA                           [---]
;  (5 ) start_month (integer) :START MONTH OF DATA                        [---]
;  (6 ) end_month   (integer) :END MONTH OF DATA                          [---]
;  (7 ) start_day   (integer) :START DAY OF DATA                          [---]
;  (8 ) end_day     (integer) :END DAY OF DATA                            [---]
;  (9 ) start_hour  (integer) :START HOUR OF DATA                         [---]
;  (10) end_hour    (integer) :END HOUR OF DATA                           [---]
;  (11) start_min   (integer) :START MINUTE OF DATA                       [---]
;  (12) end_min     (integer) :END MIMUTE OF DATA                         [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/09/2012)
;******************************************************************************

undef("filename_start_end")
procedure filename_start_end \
          (dir           :string,  filelist         :string,  \ ; INPUT
           start_year    :integer, end_year         :integer, \ ; OUTPUT
           start_month   :integer, end_month        :integer, \ ; OUTPUT
           start_day     :integer, end_day          :integer, \ ; OUTPUT
           start_hour    :integer, end_hour         :integer, \ ; OUTPUT
           start_min     :integer, end_min          :integer)   ; OUTPUT

begin

;  READ FILE NAME LIST
   fname     = asciiread(dir + filelist, -1, "string")
   nfname    = dimsizes(fname)

;  EXTRACT THE FIRST THREE STRINGS OF FILE NAME TO JUDGE WHICH SATELLITE IS
   pre       = str_get_cols(fname(0), 0, 2)

;>>>>>>>>>>>>>>>>>>>>>>>MODIS (TERRA AND AQUA)<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   if(pre .eq. "MOD")then
    print("---------------------THIS IS MODIS TERRA--------------------------")
    mopre       = str_get_cols(fname(0), 3, 7)
;  MOD021KM---RADIANCE
    if(mopre .eq. "021KM")then
     print("--------------------MODIS TERRA RADIANCE-------------------------")
     start_year = stringtoint(str_get_cols(fname(0), 10, 13))
     smotem_dn  = stringtoint(str_get_cols(fname(0), 14, 16))
     ydn2md(start_year, smotem_dn, start_month, start_day)
     start_hour = stringtoint(str_get_cols(fname(0), 18, 19))
     start_min  = stringtoint(str_get_cols(fname(0), 20, 21))
     end_year   = stringtoint(str_get_cols(fname(nfname-1), 10, 13))
     emotem_dn  = stringtoint(str_get_cols(fname(nfname-1), 14, 16))
     ydn2md(end_year, emotem_dn, end_month, end_day)
     end_hour   = stringtoint(str_get_cols(fname(nfname-1), 18, 19))
     end_min    = stringtoint(str_get_cols(fname(nfname-1), 20, 21))
;  MOD04_L2---AOD LEVEL 2
    else if(mopre .eq. "04_L2")then
     print("--------------------MODIS TERRA AOD LEVEL 2----------------------")
     start_year = stringtoint(str_get_cols(fname(0), 10, 13))
     smotem_dn  = stringtoint(str_get_cols(fname(0), 14, 16))
     ydn2md(start_year, smotem_dn, start_month, start_day)
     start_hour = stringtoint(str_get_cols(fname(0), 18, 19))
     start_min  = stringtoint(str_get_cols(fname(0), 20, 21))
     end_year   = stringtoint(str_get_cols(fname(nfname-1), 10, 13))
     emotem_dn  = stringtoint(str_get_cols(fname(nfname-1), 14, 16))
     ydn2md(end_year, emotem_dn, end_month, end_day)
     end_hour   = stringtoint(str_get_cols(fname(nfname-1), 18, 19))
     end_min    = stringtoint(str_get_cols(fname(nfname-1), 20, 21))
;  MOD14---FIRE
    else if(mopre .eq. "14.A2")then
     print("--------------------MODIS TERRA FIRE-----------------------------")
     start_year = stringtoint(str_get_cols(fname(0), 7, 10))
     smotem_dn  = stringtoint(str_get_cols(fname(0), 11, 13))
     ydn2md(start_year, smotem_dn, start_month, start_day)
     start_hour = stringtoint(str_get_cols(fname(0), 15, 16))
     start_min  = stringtoint(str_get_cols(fname(0), 17, 18))
     end_year   = stringtoint(str_get_cols(fname(nfname-1), 7, 10))
     emotem_dn  = stringtoint(str_get_cols(fname(nfname-1), 11, 13))
     ydn2md(end_year, emotem_dn, end_month, end_day)
     end_hour   = stringtoint(str_get_cols(fname(nfname-1), 15, 16))
     end_min    = stringtoint(str_get_cols(fname(nfname-1), 17, 18))
    end if
    end if
    end if
   else if(pre .eq. "MYD")then
    print("---------------------THIS IS MODIS AQUA---------------------------")
    mopre       = str_get_cols(fname(0), 3, 7)
;  MYD021KM---RADIANCE
    if(mopre .eq. "021KM")then
     print("--------------------MODIS AQUA RADIANCE--------------------------")
     start_year = stringtoint(str_get_cols(fname(0), 10, 13))
     smotem_dn  = stringtoint(str_get_cols(fname(0), 14, 16))
     ydn2md(start_year, smotem_dn, start_month, start_day)
     start_hour = stringtoint(str_get_cols(fname(0), 18, 19))
     start_min  = stringtoint(str_get_cols(fname(0), 20, 21))
     end_year   = stringtoint(str_get_cols(fname(nfname-1), 10, 13))
     emotem_dn  = stringtoint(str_get_cols(fname(nfname-1), 14, 16))
     ydn2md(end_year, emotem_dn, end_month, end_day)
     end_hour   = stringtoint(str_get_cols(fname(nfname-1), 18, 19))
     end_min    = stringtoint(str_get_cols(fname(nfname-1), 20, 21))
;  MYD04_L2---AOD LEVEL 2
    else if(mopre .eq. "04_L2")then
     print("--------------------MODIS AQUA AOD LEVEL 2-----------------------")
     start_year = stringtoint(str_get_cols(fname(0), 10, 13))
     smotem_dn  = stringtoint(str_get_cols(fname(0), 14, 16))
     ydn2md(start_year, smotem_dn, start_month, start_day)
     start_hour = stringtoint(str_get_cols(fname(0), 18, 19))
     start_min  = stringtoint(str_get_cols(fname(0), 20, 21))
     end_year   = stringtoint(str_get_cols(fname(nfname-1), 10, 13))
     emotem_dn  = stringtoint(str_get_cols(fname(nfname-1), 14, 16))
     ydn2md(end_year, emotem_dn, end_month, end_day)
     end_hour   = stringtoint(str_get_cols(fname(nfname-1), 18, 19))
     end_min    = stringtoint(str_get_cols(fname(nfname-1), 20, 21))
;  MYD14---FIRE
    else if(mopre .eq. "14.A2")then
     print("--------------------MODIS AQUA FIRE------------------------------")
     start_year = stringtoint(str_get_cols(fname(0), 7, 10))
     smotem_dn  = stringtoint(str_get_cols(fname(0), 11, 13))
     ydn2md(start_year, smotem_dn, start_month, start_day)
     start_hour = stringtoint(str_get_cols(fname(0), 15, 16))
     start_min  = stringtoint(str_get_cols(fname(0), 17, 18))
     end_year   = stringtoint(str_get_cols(fname(nfname-1), 7, 10))
     emotem_dn  = stringtoint(str_get_cols(fname(nfname-1), 11, 13))
     ydn2md(end_year, emotem_dn, end_month, end_day)
     end_hour   = stringtoint(str_get_cols(fname(nfname-1), 15, 16))
     end_min    = stringtoint(str_get_cols(fname(nfname-1), 17, 18))
    end if
    end if
    end if

;>>>>>>>>>>>>>>>>>>>>>>>CALIPSO<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   else if(pre .eq. "CAL")then
    print("---------------------THIS IS CALIPSO-----------------------------")
    mopre       = str_get_cols(fname(0), 4, 19)
;  CAL_LID_L1-ValStage1-V3-01---CALIOP LEVEL 1
    if(mopre .eq. "LID_L1-ValStage1")then
     print("--------------------CALIOP LEVEL 1-------------------------------")
     start_year = stringtoint(str_get_cols(fname(0), 27, 30))
     start_month= stringtoint(str_get_cols(fname(0), 32, 33))
     start_day  = stringtoint(str_get_cols(fname(0), 35, 36))
     start_hour = stringtoint(str_get_cols(fname(0), 38, 39))
     start_min  = stringtoint(str_get_cols(fname(0), 41, 42))
     end_year   = stringtoint(str_get_cols(fname(nfname-1), 27, 30))
     end_month  = stringtoint(str_get_cols(fname(nfname-1), 32, 33))
     end_day    = stringtoint(str_get_cols(fname(nfname-1), 35, 36))
     end_hour   = stringtoint(str_get_cols(fname(nfname-1), 38, 39))
     end_min    = stringtoint(str_get_cols(fname(nfname-1), 41, 42))
;  CAL_LID_L2_05kmAPro-Prov---CALIOP PROFILE LEVEL 2
    else if(mopre .eq. "LID_L2_05kmAPro-")then
     print("--------------------CALIOP PROFILE LEVEL 2-----------------------")
     start_year = stringtoint(str_get_cols(fname(0), 31, 34))
     start_month= stringtoint(str_get_cols(fname(0), 36, 37))
     start_day  = stringtoint(str_get_cols(fname(0), 39, 40))
     start_hour = stringtoint(str_get_cols(fname(0), 42, 43))
     start_min  = stringtoint(str_get_cols(fname(0), 45, 46))
     end_year   = stringtoint(str_get_cols(fname(nfname-1), 31, 34))
     end_month  = stringtoint(str_get_cols(fname(nfname-1), 36, 37))
     end_day    = stringtoint(str_get_cols(fname(nfname-1), 39, 40))
     end_hour   = stringtoint(str_get_cols(fname(nfname-1), 42, 43))
     end_min    = stringtoint(str_get_cols(fname(nfname-1), 45, 46))
;  CAL_LID_L2_VFM-ValStage1-V3-01---CALIOP VERTICAL FEATURE MASK LEVEL 2
    else if(mopre .eq. "LID_L2_VFM-ValSt")then
     print("--------------------CALIOP VERTICAL FEATURE MASK LEVEL 2---------")
     start_year = stringtoint(str_get_cols(fname(0), 31, 34))
     start_month= stringtoint(str_get_cols(fname(0), 36, 37))
     start_day  = stringtoint(str_get_cols(fname(0), 39, 40))
     start_hour = stringtoint(str_get_cols(fname(0), 42, 43))
     start_min  = stringtoint(str_get_cols(fname(0), 45, 46))
     end_year   = stringtoint(str_get_cols(fname(nfname-1), 31, 34))
     end_month  = stringtoint(str_get_cols(fname(nfname-1), 36, 37))
     end_day    = stringtoint(str_get_cols(fname(nfname-1), 39, 40))
     end_hour   = stringtoint(str_get_cols(fname(nfname-1), 42, 43))
     end_min    = stringtoint(str_get_cols(fname(nfname-1), 45, 46))
;  CAL_LID_L2_05kmLay-Prov---CALIOP LAYER LEVEL 2
    else if(mopre .eq. "LID_L2_05kmALay-")then
     print("--------------------CALIOP LAYER LEVEL 2-------------------------")
     start_year = stringtoint(str_get_cols(fname(0), 31, 34))
     start_month= stringtoint(str_get_cols(fname(0), 36, 37))
     start_day  = stringtoint(str_get_cols(fname(0), 39, 40))
     start_hour = stringtoint(str_get_cols(fname(0), 42, 43))
     start_min  = stringtoint(str_get_cols(fname(0), 45, 46))
     end_year   = stringtoint(str_get_cols(fname(nfname-1), 31, 34))
     end_month  = stringtoint(str_get_cols(fname(nfname-1), 36, 37))
     end_day    = stringtoint(str_get_cols(fname(nfname-1), 39, 40))
     end_hour   = stringtoint(str_get_cols(fname(nfname-1), 42, 43))
     end_min    = stringtoint(str_get_cols(fname(nfname-1), 45, 46))
    end if
    end if
    end if
    end if
;>>>>>>>>>>>>>>>>>>>>>>>VIIRS<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   else if(pre .eq. "GAE" .or. pre .eq. "GCL" .or. pre .eq. "GDN" .or. \
           pre .eq. "GIT" .or. pre .eq. "GMT" .or. pre .eq. "IIC" .or. \
           pre .eq. "IVA" .or. pre .eq. "IVC" .or. pre .eq. "RNS" .or. \
           pre .eq. "RVI" .or.                                         \
           pre .eq. "SVD" .or. pre .eq. "SVI" .or. pre .eq. "SVM" .or. \
           pre .eq. "VAO" .or. pre .eq. "VCB" .or. pre .eq. "VCC" .or. \
           pre .eq. "VCE" .or. pre .eq. "VCO" .or. pre .eq. "VCT")then
    print("---------------------THIS IS NPP VIIRS----------------------------")
    mopre       = str_get_cols(fname(0), 0, 4)
    start_year  = stringtoint(str_get_cols(fname(0), 11, 14))
    start_month = stringtoint(str_get_cols(fname(0), 15, 16))
    start_day   = stringtoint(str_get_cols(fname(0), 17, 18))
    start_hour  = stringtoint(str_get_cols(fname(0), 21, 22))
    start_min   = stringtoint(str_get_cols(fname(0), 23, 24))
    end_year    = stringtoint(str_get_cols(fname(nfname-1), 11, 14))
    end_month   = stringtoint(str_get_cols(fname(nfname-1), 15, 16))
    end_day     = stringtoint(str_get_cols(fname(nfname-1), 17, 18))
    end_hour    = stringtoint(str_get_cols(fname(nfname-1), 21, 22))
    end_min     = stringtoint(str_get_cols(fname(nfname-1), 23, 24))
;  PRINT OUT WHICH VIIRS FILE
    if(mopre .eq. "GAERO")then
     print("$$$$$$$$$$$$$$---GAERO---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "GCLDO")then
     print("$$$$$$$$$$$$$$---GCLDO---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "GDNBO")then
     print("$$$$$$$$$$$$$$---GDNBO---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "GITCO")then
     print("$$$$$$$$$$$$$$---GITCO---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "GMTCO")then
     print("$$$$$$$$$$$$$$---GMTCO---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "IICMO")then
     print("$$$$$$$$$$$$$$---IICMO---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "IVAOT")then
     print("$$$$$$$$$$$$$$---IVAOT---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "IVCLT")then
     print("$$$$$$$$$$$$$$---IVCLT---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "IVCOP")then
     print("$$$$$$$$$$$$$$---IVCOP---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "IVCTP")then
     print("$$$$$$$$$$$$$$---IVCTP---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "RNSCA")then
     print("$$$$$$$$$$$$$$---RNSCA---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "RVIRS")then
     print("$$$$$$$$$$$$$$---RVIRS---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "RVIRT")then
     print("$$$$$$$$$$$$$$---RVIRT---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVDNB")then
     print("$$$$$$$$$$$$$$---SVDNB---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVI01")then
     print("$$$$$$$$$$$$$$---SVI01---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVI02")then
     print("$$$$$$$$$$$$$$---SVI02---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVI03")then
     print("$$$$$$$$$$$$$$---SVI03---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVI04")then
     print("$$$$$$$$$$$$$$---SVI04---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVI05")then
     print("$$$$$$$$$$$$$$---SVI05---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM01")then
     print("$$$$$$$$$$$$$$---SVM01---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM02")then
     print("$$$$$$$$$$$$$$---SVM02---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM03")then
     print("$$$$$$$$$$$$$$---SVM03---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM04")then
     print("$$$$$$$$$$$$$$---SVM04---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM05")then
     print("$$$$$$$$$$$$$$---SVM05---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM06")then
     print("$$$$$$$$$$$$$$---SVM06---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM07")then
     print("$$$$$$$$$$$$$$---SVM07---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM08")then
     print("$$$$$$$$$$$$$$---SVM08---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM09")then
     print("$$$$$$$$$$$$$$---SVM09---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM10")then
     print("$$$$$$$$$$$$$$---SVM10---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM11")then
     print("$$$$$$$$$$$$$$---SVM11---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM12")then
     print("$$$$$$$$$$$$$$---SVM12---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM13")then
     print("$$$$$$$$$$$$$$---SVM13---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM14")then
     print("$$$$$$$$$$$$$$---SVM14---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM15")then
     print("$$$$$$$$$$$$$$---SVM15---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "SVM16")then
     print("$$$$$$$$$$$$$$---SVM16---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "VAOOO")then
     print("$$$$$$$$$$$$$$---VAOOO---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "VCBHO")then
     print("$$$$$$$$$$$$$$---VCBHO---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "VCCLO")then
     print("$$$$$$$$$$$$$$---VCCLO---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "VCEPO")then
     print("$$$$$$$$$$$$$$---VCEPO---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "VCOTO")then
     print("$$$$$$$$$$$$$$---VCOTO---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "VCTHO")then
     print("$$$$$$$$$$$$$$---VCTHO---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "VCTPO")then
     print("$$$$$$$$$$$$$$---VCTPO---$$$$$$$$$$$$$$$$")
    else if (mopre .eq. "VCTTO")then
     print("$$$$$$$$$$$$$$---VCTTO---$$$$$$$$$$$$$$$$")
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if    
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
   end if ; VIIRS
   end if ; CAL
   end if ; MYD
   end if ; MOD

return
end
