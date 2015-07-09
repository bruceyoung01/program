function readstd, file, Tbegin=Tbegin, Tend=Tend

if n_elements(file) eq 0 then return, 0


 hd   = ''
 Site = ''
 Name = ''
 a    = 1L
 openr,ilun,file,/get

 readf,ilun,Site,lat,lon,elev,name, $
              format='(7x,A5,7x,F5.2,7x,F7.2,8x,F6.1,A)'


 readf,ilun,hd

  Time = 1L
  ec   = 0.
  oc   = 0.
  soil = 0.
  so2  = 0.
  no3  = 0.
  amn  = 0.
  SO4  = 0.
  ams  = 0.


  while (not eof(ilun)) do begin
   readf,ilun,site,a,b,c,d,e,f,g,h,i,format = '(A5,I9,8F9.3)'
    
   time = [time,a]
   ec   = [ec,  b]
   oc   = [oc,  c]
   soil = [soil,d]
   so2  = [so2, e]
   no3  = [no3, f]
   amn  = [amn, g]
   so4  = [so4, h]
   ams  = [ams, i]
  endwhile
   
  free_lun,ilun

  it = 1
  et = N_elements(time)-1

  If N_elements(Tbegin) ne 0 Then begin
     Dt = ABS(time - Tbegin)
     it = where(min(Dt) eq Dt)
     it = it(0)
  Endif
  if N_elements(Tend) ne 0 Then begin
     Dt = ABS(time - Tend)
     et = where(Min(Dt) eq Dt)
     et = et(0)
  Endif

  if ( et lt it ) then begin
   print, 'Check Tbegin and Tend'
   return, 0
  endif

  info = improve_siteinfo()
  res  = where(site eq info.site)
  state = info.state(res[0])

  data = {siteid:strmid(site,0,4), $
          lon:lon,     $
          lat:lat,     $
          elev:elev,   $
          name:name,   $
          state:state, $
          time:time[it:et],$
          so4 : so4[it:et],$
          ams : ams[it:et],$
          no3 : no3[it:et],$
          amn : amn[it:et],$
          so2 : so2[it:et],$
          oc  :  oc[it:et],$
          ec  :  ec[it:et],$
          soil:soil[it:et]}

return, data

end
