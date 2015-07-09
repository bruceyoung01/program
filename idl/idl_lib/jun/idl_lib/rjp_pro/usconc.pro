 function process, InData, Xmid=Xmid, Ymid=Ymid

 if N_elements(Xmid) eq 0 then return, -1
 if N_elements(Ymid) eq 0 then return, -1

 West = 0.
 East = 0. 
 Iw   = 0.
 Ie   = 0.

  for i = 0, N_elements(Xmid)-1 do begin
  for j = 0, N_elements(Ymid)-1 do begin
     if InData[i,j] gt 0. then begin
       if Xmid[i] le -95. then begin
          West = West + InData[I,J]
          iw   = iw  + 1.
       endif else begin
          East = East + InData[I,J]
          ie   = ie  + 1.
       end
     endif
  endfor
  endfor

;  print, 'Grid # ', iw, ie

 return, [West/iw, East/ie]

 End

;=========================================================================;

  Tracer = [7,8,26,27,29,30,31,32,33,34,35,42,43,44,45,46,47,48,49,50]

  Year   = 2001L
  RES    = 1
  YYMM   = Year*100L + Lindgen(12) + 1L
  MTYPE  = 'GEOS3_30L'
  Diag   = 'IJ-24H-$'

;=========================================================================;
  CASE RES of
   1 : DXDY = '1x1'
   2 : DXDY = '2x25'
   4 : DXDY = '4x5' 
  END

  Modelinfo = CTM_TYPE(MTYPE, RES=RES)
  Gridinfo  = CTM_GRID(MODELINFO)

  CYear = Strtrim(Year,2)

; Observations are in ug/m3
  If N_elements(Obs) eq 0 then $
     Obs  = improve_datainfo(year=Year)

  if N_elements(std) eq 0 then begin

     ; Calculation output is in umoles/m3
     if !D.name ne 'WIN' then filter = '/users/ctm/rjp/Asim/' 

     If N_elements(file_calc) eq 0 then $
     file_calc = dialog_pickfile(filter=filter)

     read_model,             $
        file_calc,           $
        Diag,                $
        Tracer=Tracer,       $
        YYMM = YYMM,         $               
        Modelinfo=Modelinfo, $
        calc=std,   $
        obs=Obs
  endif


 Dim = Size(Std.SO4_CONC,/Dim)
 spec = ['aSO4','aNIT','NH4','EC','OMC','SOA','POA','SSA','SSC','NH3','SO2','HNO3']
 NSPEC = N_ELEMENTS(SPEC)
 CSPEC = strtrim(nspec,2)
 FLD = fltarr(Dim[0],Dim[1],nspec)
 OUT = FLTARR(2,nspec)

 FLD[*,*,0]  = (Std.SO4_CONC*96.) + (Std.NH4_CONC*18.) - (Std.NIT_CONC*62.*0.29) ; ammonium sulfate
 FLD[*,*,1]  = Std.NIT_CONC*62.*1.29                                             ; Ammonium NITRATE
 FLD[*,*,2]  = Std.NH4_CONC * 18.                        ; AMMONIUM
 FLD[*,*,3]  = (STD.ECPI_CONC+STD.ECPO_CONC)*12.         ; ELEMENTAL CARBON
 FLD[*,*,4]  = (STD.ocpi_conc+STD.ocpo_conc)*12.*1.4 $
             + (STD.soa1_conc)*150.                  $
             + (STD.soa2_conc)*160.                  $
             + (STD.soa3_conc)*220.
 FLD[*,*,5]  = (STD.soa1_conc)*150.                  $
             + (STD.soa2_conc)*160.                  $
             + (STD.soa3_conc)*220.
 FLD[*,*,6]  = (STD.ocpi_conc+STD.ocpo_conc)*12.*1.4
; FLD[*,*,6] = (STD.dst1_conc + STD.dst2_conc*0.38)*29.  ; FINE DUST
; FLD[*,*,7] = STD.sala_conc*36.  ; FINE SEA SALT
; FLD[*,*,8] = STD.salc_conc*36.  ; COARSE SEA SALT
 FLD[*,*,9]  = Std.NH3_CONC * 17. ; AMMONIA
 FLD[*,*,10] = Std.SO2_CONC * 64. ; SULFUR DIOXIDE
 FLD[*,*,11] = STD.hno3_conc*63.  ; NITRIC ACID

 IW = where(obs.lon le -95.) 
 IE = where(obs.lon gt -95.)

 Openw, il, 'usconc_noasia_1x1.txt', /get

 Print, 'TIME',spec,format='(12x,a6,'+CSPEC+'a7)'
 Printf, il, 'TIME',spec,format='(12x,a6,'+CSPEC+'a7)'
 For D = 0, N_elements(YYMM)-1 do begin

   FOR N = 0, nspec-1L DO BEGIN
      OUT[0,N] = mean(reform(FLD[IW,D,N]))
      OUT[1,N] = mean(reform(FLD[IE,D,N]))
   END

   print, 'Conc (West) ', YYMM[D], Reform(OUT[0,*]), format='(A12,I6,'+CSPEC+'F7.3)'
   print, 'Conc (East) ', YYMM[D], Reform(OUT[1,*]), format='(A12,I6,'+CSPEC+'F7.3)'

   Printf, il, '    '
   printf, il, 'Conc (West) ', YYMM[D], Reform(OUT[0,*]), format='(A12,I6,'+CSPEC+'F7.3)'
   printf, il, 'Conc (East) ', YYMM[D], Reform(OUT[1,*]), format='(A12,I6,'+CSPEC+'F7.3)'

 Endfor

   FOR N = 0, nspec-1L DO BEGIN
      OUT[0,N] = mean(reform(FLD[IW,*,N]))
      OUT[1,N] = mean(reform(FLD[IE,*,N]))
   END

   print, 'Conc (West) ', Year, Reform(OUT[0,*]), format='(A12,I6,'+CSPEC+'F7.3)'
   print, 'Conc (East) ', Year, Reform(OUT[1,*]), format='(A12,I6,'+CSPEC+'F7.3)'

   Printf, il, '    '
   printf, il, 'Conc (West) ', Year, Reform(OUT[0,*]), format='(A12,I6,'+CSPEC+'F7.3)'
   printf, il, 'Conc (East) ', Year, Reform(OUT[1,*]), format='(A12,I6,'+CSPEC+'F7.3)'

 free_lun, il

; undefine, std
; undefine, file_calc

 End
