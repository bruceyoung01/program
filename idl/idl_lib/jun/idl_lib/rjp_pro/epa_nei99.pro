 Tracer = 26L & MW = 32 ; SO2 as S
; Tracer = 27L & MW = 32 ; SO4 as S
; Tracer = 29L & MW = 14 ; NH3 as N
; Tracer = 34L & MW = 12 ; EC as C
; Tracer = 35L & MW = 12 ; OC as C

 spawn, 'ls /data/ctm/GEOS_1x1_NA/EPA_NEI_200411/wkday_avg_an*', wkday_files
 spawn, 'ls /data/ctm/GEOS_1x1_NA/EPA_NEI_200411/wkend_avg_an*', wkend_files

 Data_wkday = 0.
 Data_wkend = 0.
 ; month by month
 For D = 0, N_elements(wkday_files)-1 do begin
   ; unit molec/cm2/s
   Ctm_get_data, datainfo, file=wkday_files[D], tracer=tracer
   Data_wkday = Data_wkday + *(Datainfo.data)

   Ctm_get_data, datainfo, file=wkend_files[D], tracer=tracer
   data_wkend = Data_wkend + *(Datainfo.data)
 End

 ; annual mean (molec/cm2/s)
 Data_wkday = Data_wkday / float(N_elements(wkday_files)) 
 Data_wkend = Data_wkend / float(N_elements(wkday_files))

; 52 weeks for one year
 Nday_wkend = 52. * 2.
 Nday_wkday = 365. - Nday_wkend


 GridInfo = Ctm_grid(Ctm_type('GEOS3', res=1)) 
 Area = CTM_BOXSIZE( GridInfo, /GEOS, /cm2 )
 Area_nested = reform(Area[40:140,100:150])

 Data_wkday = Data_wkday * Area_nested * Nday_wkday * 86400. * MW / 6.022E23
 Data_wkend = Data_wkend * Area_nested * Nday_wkend * 86400. * MW / 6.022E23

 print, total(Data_wkday + Data_wkend) * 1.e-12 ; Tg /yr

 End
