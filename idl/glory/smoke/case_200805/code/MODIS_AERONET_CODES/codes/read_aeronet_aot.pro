 ; read aeronet hourly AOD

; Interface:

  PRO read_aeronet_aod, filename, $
       YY = YY, MM = MM, DD = DD, $
       Time = Time, JulianD = JulianD,       $
       AOD_675 = AOT_675, AOD_440 = AOT_440

  readcol, filename, YY, MM, DD, Time, JulianD, SZA,                $
           AOT_1640, AOT_1020, AOT_870, AOT_675, AOT_667, AOT_555,  $
           AOT_551,  AOT_532,  AOT_531, AOT_500, AOT_490, AOT_443,  $
           AOT_440,  AOT_412,  AOT_380, AOT_340,                    $
           format = 'I, I, I, F, F, F, F, F, F, F, F, F, F, F, F,'+ $
                    'F, F, F, F, F, F, F', skipline = 1


  YY = YY
  MM = MM
  DD = DD
  Time = Time
  AOD_675 = AOD_675
  AOD_440 = AOD_440


  RETURN

  END

; ------ end subroutine

