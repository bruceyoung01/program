; $ID; selected_wrf_calipso.ncl V01 02/16/2012 15:12 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE selected_wrf_calipso SELECTS THE SELECTED WRFCHEM DATA BASED ON 
;  CALIPSO GROUND TRACK.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) in      (integer): TOTAL # OF SELECTED WRFCHEM GRIDS            [---]
;  (2 ) aspm25h1(float)  : SELECTED WRFCHEM PM2.5 DATA                  [um/m3]
;  (3 ) aspth1  (float)  : SELECTED WRFCHEM TEMPERATURE                 [C  ]
;  (4 ) aspblh1 (float)  : SELECTED WRFCHEM PLANET BOUNDARY LAYER HEIGHT[m  ]
;  (5 ) sspm25h (float)  : NEW SELECTED WRFCHEM PM2.5 DATA              [um/m3]
;  (6 ) sspth   (float)  : NEW SELECTED WRFCHEM TEMPERATURE             [C  ]
;  (7 ) sspblh  (float)  : NEW SELECTED WRFCHEM PLANET BOUNDARY LAYER 
;                          HEIGHT                                       [m  ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/16/2012)
;
;******************************************************************************


undef("selected_wrf_calipso")
procedure selected_wrf_calipso(in      :integer, aspm25h1 :float, \; INPUT
                               aspth1  :float,   aspblh1  :float, \; INPUT
                               sspm25h :float,   sspth    :float, \; OUTPUT
                               sspblh  :float)                     ; OUTPUT

begin
   sspm25h = aspm25h1(:,0:in-2)
   sspth   = aspth1(:,0:in-2)
   sspblh  = aspblh1(0:in-2)

return
end
