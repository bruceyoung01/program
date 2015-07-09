 function get_pedge, ps, modelinfo=modelinfo

   if n_elements(ps) gt 1 then $
      message, 'ps should be a scala variable'
   ; calculate column pressure

   ; Retrieve model coordinate and some constants for unit conversion
   GridInfo = CTM_GRID( MOdelInfo )

   ; a pure sigma coordinate
   if strmid(modelinfo.name,0,5) eq 'GEOS3' then begin

      PTOP    = min(GRIDINFO.PEDGE)
      BP      = GRIDINFO.sigedge
      AP      = Replicate(PTOP, N_elements(BP))

      PEDGE   = AP + ( BP * ( PS - PTOP ) )

   ; a hybrid sigma-pressure
   end else if STRMID(MODELINFO.NAME,0,5) eq 'GEOS4' then begin

      ; Ap [hPa] for 30 levels (31 edges)
      AP = [   0.000000d0,   0.000000d0,  12.704939d0,  35.465965d0,  $
              66.098427d0, 101.671654d0, 138.744400d0, 173.403183d0,  $
             198.737839d0, 215.417526d0, 223.884689d0, 224.362869d0,  $
             216.864929d0, 201.192093d0, 176.929993d0, 150.393005d0,  $
             127.837006d0, 108.663429d0,  92.365662d0,  78.512299d0,  $
              56.387939d0,  40.175419d0,  28.367815d0,  19.791553d0,  $
               9.292943d0,   4.076567d0,   1.650792d0,   0.616779d0,  $
               0.211349d0,   0.066000d0,   0.010000d0 ]

      ; Bp [unitless] for 30 levels (31 edges)
      BP = [   1.000000d0,   0.985110d0,   0.943290d0,   0.867830d0,  $
               0.764920d0,   0.642710d0,   0.510460d0,   0.378440d0,  $
               0.270330d0,   0.183300d0,   0.115030d0,   0.063720d0,  $
               0.028010d0,   0.006960d0,   0.000000d0,   0.000000d0,  $
               0.000000d0,   0.000000d0,   0.000000d0,   0.000000d0,  $
               0.000000d0,   0.000000d0,   0.000000d0,   0.000000d0,  $
               0.000000d0,   0.000000d0,   0.000000d0,   0.000000d0,  $
               0.000000d0,   0.000000d0,   0.000000d0 ] 

      PTOP    = min(GRIDINFO.PEDGE)
      PEDGE   = AP + ( BP * ps )

    end else if STRMID(MODELINFO.NAME,0,4) eq 'GCAP'  THEN begin

      ; Define SIGMA edges from GISS 23L model
      SIGE_GCAP = [  1.0d0,           0.9712230d0,     0.9340528d0,     $
                     0.8800959d0,     0.8021583d0,     0.6714628d0,     $
                     0.5035971403d0,  0.3297362030d0,  0.1966426820d0,  $
                     0.1139088720d0,  0.0503597111d0,  0.0000000000d0,  $
                    -0.0395683460d0, -0.0764988065d0, -0.1124700233d0,  $
                    -0.1419664323d0, -0.1585131884d0, -0.1678657085d0,  $
                    -0.1743045598d0, -0.1781055182d0, -0.1793033630d0,  $
                    -0.1796822548d0, -0.1798187047d0, -0.1798536479d0  ]

      PTOP    = min(GRIDINFO.PEDGE)
      AP      = FLTARR( N_elements(SIGE_GCAP) )
      BP      = AP

      ; Convert SIGMA to AP and BP coordinates
      AP[0:11] = 150d0 + ( SIGE_GCAP[0:11] * ( PTOP - 150d0 ) )
      BP[0:11] = SIGE_GCAP[0:11]
      AP[12:*] = 150d0 + ( SIGE_GCAP[12:*] * ( 984d0 - 150d0 ) )
      BP[12:*] = 0d0

      PEDGE = AP + ( BP * ( PS - PTOP ) )

    end


    A = [  0.0000000,   6.3524695,  24.085452,  50.782196,  83.885041, $
         120.2080300, 156.0737900, 186.070510, 207.077680, 219.651110, $
         224.1237800, 220.6139000, 209.028510, 189.061040, 163.661500, $
         139.1150100, 118.2502200, 100.514550,  85.438980,  67.450119, $ 
          48.2816790,  34.2716170,  24.079684,  14.542248,   6.684755, $ 
           2.8636795,   1.1337855,   0.414064,   0.138675,   0.038000]

    B = [ 0.99255500, 0.96420000, 0.90556000, 0.81637500, 0.70381500,  $
          0.57658500, 0.44445000, 0.32438500, 0.22681500, 0.14916500,  $
          0.08937500, 0.04586500, 0.01748500, 0.00348000, 0.00000000,  $
          0.00000000, 0.00000000, 0.00000000, 0.00000000, 0.00000000,  $
          0.00000000, 0.00000000, 0.00000000, 0.00000000, 0.00000000,  $
          0.00000000, 0.00000000, 0.00000000, 0.00000000, 0.00000000]



;      delp    = (shift(pedge,1))[1:*] - pedge[1:*]
;      press   = ((shift(pedge,1))[1:*] + pedge[1:*])*0.5

  return, pedge

 end
