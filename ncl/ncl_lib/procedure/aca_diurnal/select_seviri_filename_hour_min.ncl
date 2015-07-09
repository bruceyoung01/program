;  $ID: select_seviri_filename_hour_min.ncl V01 07/01/2015 16:03 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM select_seviri_filename_hour_min.ncl SELECTS ALL THE FILE NAMES BASED
;  ON THE CASE, METHOD, HOUR, AND MINUTE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/01/2015)
;******************************************************************************
undef("select_seviri_filename_hour_min")
procedure select_seviri_filename_hour_min \
          (filename         :string,                            \;INPUT
           case             :string,  method          :string,  \;INPUT
           hour             :integer, minute          :integer, \;INPUT
           sfilename        :string,  nsfilename_real :integer, \;OUTPUT
           logic_continue   :logical)                            ;OUTPUT

begin

;  CONVERT hour AND minute TO STRING
   sshour  = sprinti("%0.2i", hour)
   ssminute= sprinti("%0.2i", minute)

;  GET CASE, METHOD, HOUR, AND MINUTE FROM FILENAME
   scase   = str_get_cols(filename, -50, -38)
   smethod = str_get_cols(filename, -36, -32)
   shour   = str_get_cols(filename, -17, -16)
   smin    = str_get_cols(filename, -14, -13)
;print(scase + " | " + smethod)
;print(shour + " | " + smin)
;  SELECT FILE NAME FOR SPECIFIC CASE, METHOD, HOUR, AND MINUTE
   index   = ind(scase   .eq. case   .and. \
                 smethod .eq. method .and. \
                 shour   .eq. sshour .and. \
                 smin    .eq. ssminute)

   if (.not.all(ismissing(index))) then
      nindex                = dimsizes(index)
      sfilename(0:nindex-1) = filename(index)
      nsfilename_real       = num(.not.ismissing(index))
print("selected SEVIRI file = " + filename(index))
   else
      logic_continue = True
   end if
   delete([/index/])

return
end
