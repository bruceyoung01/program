;  $ID: select_aca_grid_file.ncl V01 05/17/2015 21:48 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_aca_grid_file SELECTS ACA GRIDDED FILE BASED ON THE YEAR, 
;  MONTH, DAY, AND READS VARIABLES
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/17/2015)
;******************************************************************************

undef("select_aca_grid_file")
procedure select_aca_grid_file \
          (filename        :string,                           \ ;INPUT
           iyear           :integer, imonth         :integer, \ ;INPUT
           iday            :integer,                          \ ;INPUT
           dorn            :string,  just           :string,  \ ;INPUT
           sfilename       :string,  logic_filename :logical)   ;OUTPUT


begin
;  EXTRACT YEAR, MONTH, AND DAY FROM THE FILE NAME ARRAY
   wyear    = stringtoint(str_get_cols(filename, 11, 14))
   wmonth   = stringtoint(str_get_cols(filename, 16, 17))
   wday     = stringtoint(str_get_cols(filename, 19, 20))
   wdorn    = str_get_cols(filename, 22, 22)
   wjust    = str_get_cols(filename, -10, -4)
   index    = ind(wyear  .eq. iyear  .and. \
                  wmonth .eq. imonth .and. \
                  wday   .eq. iday   .and. \
                  wdorn  .eq. dorn   .and. \
                  wjust  .eq. just)

   if (.not. all(ismissing(index))) then
      print("Selected File : " + filename(index))
      sfilename = filename(index)
   else
      print("==============================NOTICE====================================")
      print("File name does not exist")
      logic_filename = False
   end if

return
end
