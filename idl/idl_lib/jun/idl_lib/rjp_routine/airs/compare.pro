
if n_elements(aqs) eq 0 then aqs = aqs_datainfo()
if n_elements(air) eq 0 then air = airnow_datainfo()

first = 0L

for D = 0, n_elements(air)-1 do begin

  id = strmid(air[D].siteid,0,9)
  p  = where(aqs.siteid eq id)

  if p[0] ne -1L then begin

     x = air[D].so4
     y = aqs[P[0]].so4
     if first eq 0L then begin
     plot, x, y, psym=1, color=1, $
       xrange=[-2.,30.], yrange=[-2.,30.]
     first = 1L
     end else $   
     oplot, x, y, psym=1, color=1
     
  end else $
     print, air[D].siteid

end

end
