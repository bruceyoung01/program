;  $ID: convert_amsre.ncl V01 06/10/2015 18:03 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE convert_amsre.ncl CONVERTS AMSR-E DATA TO REAL DATA AFTER 
;  READING FROM THE BINARY FILES.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) bv2              (float):MISSING VALUE                            [   ]
;  (2 ) nday_or_night  (integer):# OF DAY AND NIGHT                       [   ]
;  (3 ) nelement       (integer):# OF PARAMETERS FROM AMSR-E DATA         [   ]
;  (4 ) camsre_data  (character):AMSR-E DATA WITH DATA TYPE OF CHARACTER  [   ]
;  (5 ) xscale           (float):SCALE FACTOR FROM REMSS.COM DATABASE     [   ]
;  (6 ) xoffset          (float):OFFSET FROM REMSS.COM DATABASE           [   ]
;  (7 ) amsre_data       (float):THE WHOLE DATA                           [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/10/2015)
;******************************************************************************

undef("convert_amsre")
procedure convert_amsre \
          (bv2           :float,   nday_or_night    :integer,   \ ;INPUT
           nelement      :integer, camsre_data      :character, \ ;INPUT
           xscale        :float,   xoffset          :float,     \ ;INPUT
           amsre_data    :float)                                  ;OUTPUT

begin
   amsre_data  = charactertofloat(camsre_data)
   amsre_data@_FillValue = bv2
;  MULTIPLIERS TO XSCALE AND XOFFSET
   do iday_or_night = 0, nday_or_night-1
      do ielement = 0, nelement-1
         amsre_data(iday_or_night, ielement, :, :) = \
         where(amsre_data(iday_or_night, ielement, :, :) .gt. 250, bv2, \
               amsre_data(iday_or_night, ielement, :, :))
               amsre_data(iday_or_night, ielement, :, :) = \
         where(amsre_data(iday_or_night, ielement, :, :) .le. 250, \
               amsre_data(iday_or_night, ielement, :, :)* \
               xscale(ielement)+xoffset(ielement),        \
               amsre_data(iday_or_night, ielement, :, :))
      end do
   end do
;  CONVERT CLOUD LIQUID WATER PATH UNIT FROM mm to g/m^2
;  1mm = 0.001m = 0.001*10^6g/m^2 = 10^3g/m^2
   amsre_data(:, 5, :, :) = (/amsre_data(:, 5, :, :)/)*1000.0

return
end
