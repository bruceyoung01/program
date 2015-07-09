 ; PRO read DNB files
  PRO read_dnb_picked_201208_10, DIRPicked, siteid, YYP, MonP, DDP, HHP, MMP, SSP, $
      rad, vza, Mphase, MFrac

 if (siteid eq 'A') then begin 
 readcol, dirpicked + 'Site' + siteid + '_pickup_201208_10.txt', $
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
 readcol, dirpicked + 'Site' + siteid + '_Angle_one_201208_10.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, mvza, $
          mazm, satvza, satazm, ssza, sazm, mphase, mfrac, $
          F = '(A, A, A, A, A, A, F, F, F, F, F, F, F, F)'     
          nvar = 1
          vza = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              vza[*, j] = satvza
          endfor 
 endif
 
 if (siteid eq 'B') then begin 
 readcol, dirpicked + 'Site' + siteid + '_pickup_201208_10.txt', $
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
 readcol, dirpicked + 'Site' + siteid + '_Angle_one_201208_10.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, mvza, $
          mazm, satvza, satazm, ssza, sazm, mphase, mfrac,  $
          F = '(A, A, A, A, A, A,  F, F, F, F, F, F, F, F)'     
          nvar =9 
          nl = n_elements(YYP)
          vza = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              vza[*, j] = satvza
          endfor 
 endif

 if (siteid eq 'C') then begin 
 readcol, dirpicked + 'Site' + siteid + '_pickup_201208_10.txt', $
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
 readcol, dirpicked + 'Site' + siteid + '_Angle_one_201208_10.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, mvza, $
          mazm, satvza, satazm, ssza, sazm, mphase, mfrac, $
          F = '(A, A, A, A, A, A, F, F, F, F, F, F, F, F)'     
          nvar = 1
          nl = n_elements(YYP)
          vza = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              vza[*, j] = satvza
          endfor 
 endif

 if (siteid eq 'D') then begin 
 readcol, dirpicked + 'Site' + siteid + '_pickup_201208_10.txt', $
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
 readcol, dirpicked + 'Site' + siteid + '_Angle_one_201208_10.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, mvza, $
          mazm, satvza, satazm, ssza, sazm, mphase, mfrac, $
          F = '(A, A, A, A, A, A,  F, F, F, F, F, F, F, F)'     
          nvar = 1
          nl = n_elements(YYP)
          vza = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              vza[*, j] = satvza
          endfor 
 endif

 if (siteid eq 'E') then begin 
 readcol, dirpicked + 'Site' + siteid + '_pickup_201208_10.txt', $
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
 readcol, dirpicked + 'Site' + siteid + '_Angle_one_201208_10.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, mvza, $
          mazm, satvza, satazm, ssza, sazm, mphase, mfrac, $
          F = '(A, A, A, A, A, A, F, F, F, F, F, F, F, F)'     
          nvar = 1
          vza = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              vza[*, j] = satvza
          endfor 
 endif

 if (siteid eq 'CTR') then begin 
 readcol, dirpicked + 'Site' + siteid + '_pickup_201208_10.txt', $
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
 readcol, dirpicked + 'Site' + siteid + '_Angle_one_201208_10.txt', $
          YYP, MonP, DDP, HHP, MMP, SSP, mvza, $
          mazm, satvza, satazm, ssza, sazm, mphase, mfrac, $
          F = '(A, A, A, A, A, A, I, I, I, I, F, F, F, F, F, F, F, F)'     
          nvar = 1
          vza = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              vza[*, j] = satvza
          endfor 
 endif

 END

