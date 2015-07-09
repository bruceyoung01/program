 function region_only, fd2d, Region=region, null=null, npts=npts
;+
; function region_only, fd2d, Region=region
; Region Options are
; 'US', 'CANADA', 'CAMERICA', 'AMERICA', 'EUROPE', 'ASIA'
; fd2d can be either 2D array or 3D array
;-

 If N_elements(Region) ne 0 then Region = strupcase(region) else $
    Return, fd2d
 If N_elements(Null)   eq 0 then Null   = 0.

 Case Region of 
   'US'      : CTN = 'US'
   'USCONT'  : CTN = 'UScont'
   'USBOX'   : CTN = 'USbox'
   'CANADA'  : CTN = 'Canada'
   'MEXICO'  : CTN = 'MEXICO'
   'NAMERICA': CTN = 'N.America'
   'CAMERICA': CTN = 'C.America'
   'AMERICA' : CTN = 'N+C.America'
   'EUROPE'  : CTN = 'EUROPE'
   'ASIA'    : CTN = 'ASIA'
   'NPACIFIC': CTN = 'N.Pacific'
   'CHINA'   : CTN = 'CHINA'
   'KORJAP'  : CTN = 'KORJAP'
   'INDIA'   : CTN = 'INDIA'
   'SEASIA'  : CTN = 'SEASIA'
   'GLOBE'   : return, fd2d
   Else      : begin
               print, 'Sorry !! No corresponding Region found'
               print, 'Try differently'
               Return, 0
               end
 Endcase

 DIM = SIZE(FD2D)
 IMX = DIM[1]
 JMX = DIM[2]
 IF DIM[0] eq 3 then LMX = DIM[3] else LMX = 1L

 CASE DIM[1] OF 
    360 : Res  = '1x1'
    144 : Res  = '2x25'
     72 : Res  = '4x5'
    101 : Res  = '1x1'   ; North America nested 1x1 run
    else: begin
          print, 'Sorry !! No corresponding model resolution found'
          print, 'Try differently'
          Return, 0
          end
 ENDCASE

 File = '/users/ctm/rjp/Data/MAP/'+CTN+'.map_'+Res+'.bin'

 If N_elements(file) eq 0 then return, 0

   FLAG = FLTARR( IMX, JMX )    
   TEMP = FD2D

   nested = 0L
   ; nested 1x1 run over NA
   if IMX eq 101 then begin
      nested = 1L
      flag = fltarr(360,181)  ; 1x1 globally
      TEMP = FLTARR(360,181,LMX)
      TEMP[40:140,100:150,*] = FD2D[*,*,*]
   end

   Openr,il,file,/f77,/get
   readu,il,flag
   free_lun,il

   Npts = float(N_elements(where(flag eq 1.)))

   for T = 0L, LMX-1L do $
       temp[*,*,t] = temp[*,*,t] * flag[*,*]

  if nested eq 1L then $
     Temp = reform(Temp[40:140,100:150,*])

  return, Temp

 end
