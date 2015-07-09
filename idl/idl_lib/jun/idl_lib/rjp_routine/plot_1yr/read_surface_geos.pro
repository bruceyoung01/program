; $Id: read_surface_geos.pro,v 1.2 2003/12/08 19:35:00 bmy Exp $
pro read_surface_geos, species, sta, sta1, out, std

   pressure=fltarr(25) ; for final model?
   pressure=[1000,900,800,700,600,500,400,350,300,250,200,175,150,$
             125,100,90,80,70,60,50,40,30,20,15,10]


   out=fltarr(12)
   std=fltarr(12)

   ndays=intarr(12)
   ndays=[31,28,31,30,31,30,31,31,30,31,30,31]
 
   ; Open file
   fId  = NCDF_Open( sta )

   ; Get Pressures
   Pressure = NCDF_get( fId, 'pressure' )

   ;;print, Pressure

   ; Contituent labels
   ; STRING will convert BYTE values to a STRING
   Labels = String( ncdf_get( fId, 'const_labels' ) )
   ;;print, Labels

        
   ; Data file
   Data = NCDF_get( fId, 'const' )


   ; Pull out O3 only
   ; Modify it for whatever species you want....
   Ind = Where( StrUpCase( StrTrim( Labels, 2 ) ) eq species)

   ; Pull out the proper month
   O3Data = Reform(Data[0,Ind,*] )

   ; For stations on the higher altitudes

   if sta1 eq 'CUI' or sta1 eq 'LEF' or sta1 eq 'UUM' or sta1 eq 'UTA' then begin
   O3Data = Reform(Data[1,Ind,*] )
   endif

   if sta1 eq 'IZO' or sta1 eq 'MLO' then begin
   O3Data = Reform(Data[2,Ind,*] )
   endif

   if sta1 eq 'NWR' or sta1 eq 'SPO' then begin
   O3Data = Reform(Data[3,Ind,*] )
   endif
 
   if sta1 eq 'WLG' then begin
   O3Data = Reform(Data[4,Ind,*] )
   endif

   ; Now get monthly means for 12 ( 4 ) months we are going to plot

for i=0,11 do begin 
  
   if i eq 0 then first=0
   if i gt 0 then first=total(ndays[0:(i-1)])*24
   last=first+ndays[i]*24-1

   out[i] = mean(O3Data[first:last])
   std[i]=stddev(O3Data[first:last])

   ;print, out[i]
   ;print, std[i]
endfor
   ;print, out
   ;print, std
   ; Close file
   NCDF_Close, fId

close,/all


return
end
