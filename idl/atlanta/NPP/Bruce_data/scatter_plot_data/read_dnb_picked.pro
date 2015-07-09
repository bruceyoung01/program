 ; PRO read DNB files
  PRO read_dnb_picked, DIRPicked, siteid, YYP, MonP, DDP, HHP, MMP, SSP, $
      rad, vza, Mphase, MFraction

 if (siteid eq 'A') then begin 
 readcol, dirpicked + 'Site' + siteid + '_pickup.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, npul, nlul, np0, nl0, rad1, rad2, $
          rad3, rad4, rad5, rad6, rad7, rad8, rad9, rad10, $
          F = '(A, A, A, A, A, A, I, I, I, I, F, F, F, F, F, F, F, F, F, F )'     
          nl = n_elements(YYP)
          nvar = 10
          rad = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('rad'+strtrim(j+1, 2))
              tst = execute( 'rad[*, j] = ' + tmp+ '[*]' )     
          endfor 
 readcol, dirpicked + 'Site' + siteid + '_Angle.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, A1, A2, $
          A3, A4, A5, A6, A7, A8, A9, A10, Mphase, Mfraction, $
          F = '(A, A, A, A, A, A, F, F, F, F, F, F, F, F, F, F, F, F )'     
          nvar = 10
          vza = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('A'+strtrim(j+1, 2))
              tst = execute( 'vza[*, j] = ' + tmp+ '[*]' )     
          endfor 
 endif
 
 if (siteid eq 'B') then begin 
 readcol, dirpicked + 'Site' + siteid + '_pickup.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, npul, nlul, np0, nl0, rad1, rad2, $
          rad3, rad4, rad5, rad6, rad7, rad8, rad9,   $
          F = '(A, A, A, A, A, A, I, I, I, I, F, F, F, F, F, F, F, F, F, )'     
          nvar = 9
          nl = n_elements(YYP)
          rad = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('rad'+strtrim(j+1, 2))
              tst = execute( 'rad[*, j] = ' + tmp+ '[*]' )     
          endfor 
 readcol, dirpicked + 'Site' + siteid + '_Angle.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, A1,  A2, $
          A3, A4, A5, A6, A7, A8, A9, Mphase, Mfraction,  $
          F = '(A, A, A, A, A, A,  F, F, F, F, F, F, F, F, F, F, F)'     
          nvar =9 
          nl = n_elements(YYP)
          vza = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('A'+strtrim(j+1, 2))
              tst = execute( 'vza[*, j] = ' + tmp+ '[*]' )     
          endfor 
 endif

 if (siteid eq 'C') then begin 
 readcol, dirpicked + 'Site' + siteid + '_pickup.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, npul, nlul, np0, nl0, rad1, rad2, $
          rad3, rad4, rad5, rad6, rad7,  $
          F = '(A, A, A, A, A, A, I, I, I, I, F, F, F, F, F, F, F)'     
          nvar = 7
          nl = n_elements(YYP)
          rad = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('rad'+strtrim(j+1, 2))
              tst = execute( 'rad[*, j] = ' + tmp+ '[*]' )     
          endfor 
 readcol, dirpicked + 'Site' + siteid + '_Angle.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, A1, A2, $
          A3, A4, A5, A6, A7, Mphase, Mfraction, $
          F = '(A, A, A, A, A, A, F, F, F, F, F, F, F, F, F)'     
          nvar = 7
          nl = n_elements(YYP)
          vza = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('A'+strtrim(j+1, 2))
              tst = execute( 'vza[*, j] = ' + tmp+ '[*]' )     
          endfor 
 endif

 if (siteid eq 'D') then begin 
 readcol, dirpicked + 'Site' + siteid + '_pickup.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, npul, nlul, np0, nl0, rad1, rad2, $
          rad3, rad4, rad5,  $
          F = '(A, A, A, A, A, A, I, I, I, I, F, F, F, F, F)'     
          nvar = 5
          nl = n_elements(YYP)
          rad = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('rad'+strtrim(j+1, 2))
              tst = execute( 'rad[*, j] = ' + tmp+ '[*]' )     
          endfor 
 readcol, dirpicked + 'Site' + siteid + '_Angle.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP,  A1, A2, $
          A3, A4, A5, Mphase, Mfraction, $
          F = '(A, A, A, A, A, A,  F, F, F, F, F, F, F)'     
          nvar = 5
          nl = n_elements(YYP)
          vza = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('A'+strtrim(j+1, 2))
              tst = execute( 'vza[*, j] = ' + tmp+ '[*]' )     
          endfor 
 endif

 if (siteid eq 'E') then begin 
 readcol, dirpicked + 'Site' + siteid + '_pickup.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, npul, nlul, np0, nl0, rad1, rad2, $
          rad3, rad4, rad5, rad6, rad7, rad8, rad9, rad10, rad11, rad12, rad13,  $
          rad14, rad15, $
          F = '(A, A, A, A, A, A, I, I, I, I, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F)'     
          nvar = 15
          nl = n_elements(YYP)
          rad = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('rad'+strtrim(j+1, 2))
              tst = execute( 'rad[*, j] = ' + tmp+ '[*]' )     
          endfor 
 readcol, dirpicked + 'Site' + siteid + '_Angle.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, A1, A2, $
          A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13,  $
          A14, A15, Mphase, MFraction, $
          F = '(A, A, A, A, A, A, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F)'     
          nvar = 15 
          vza = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('A'+strtrim(j+1, 2))
              tst = execute( 'vza[*, j] = ' + tmp+ '[*]' )     
          endfor 
 endif

 if (siteid eq 'CTR') then begin 
 readcol, dirpicked + 'Site' + siteid + '_pickup.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, npul, nlul, np0, nl0, rad1, rad2, $
          rad3, rad4, rad5, rad6, rad7, rad8, rad9, rad10, rad11, rad12, rad13,  $
          rad14, rad15, rad16, rad17, rad18, rad19, rad20, rad21, rad22, rad23, rad24, rad25, $
          F = '(A, A, A, A, A, A, I, I, I, I, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F)'     
          nvar = 25
          nl = n_elements(YYP)
          rad = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('rad'+strtrim(j+1, 2))
              tst = execute( 'rad[*, j] = ' + tmp+ '[*]' )     
          endfor 
 readcol, dirpicked + 'Site' + siteid + '_Angle.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, A1, A2, $
          A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13,  $
          A14, A15, A16, A17, A18, A19, A20, A21, A22, A23, A24, A25, Mphase, MFraction, $
          F = '(A, A, A, A, A, A, I, I, I, I, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F)'     
          nvar = 25 
          vza = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('A'+strtrim(j+1, 2))
              tst = execute( 'vza[*, j] = ' + tmp+ '[*]' )     
          endfor 
 endif

 END

