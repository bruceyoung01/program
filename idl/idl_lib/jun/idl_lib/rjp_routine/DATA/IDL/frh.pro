
 data = imp_dinfo(year=2001L)
 west = 0.
 east = 0.

 for d = 0, n_elements(data.siteid)-1 do begin

   if data.lon[d] gt -135. and data.lon[d] le -95. then begin
      sum = 0.
      ict = 0.
      for m = 0, 11 do begin
          if data.frh[d,m] gt 0. then begin
             sum = sum + data.frh[d,m]
             ict = ict + 1.
          end
      end
      if ict eq 12 then west = [west, sum/ict]
   end

   if data.lon[d] gt -95. then begin
      sum = 0.
      ict = 0.
      for m = 0, 11 do begin
          if data.frh[d,m] gt 0. then begin
             sum = sum + data.frh[d,m]
             ict = ict + 1.
          end
      end
      if ict eq 12 then east = [east, sum/ict]
   end
 endfor

 west = west[1:*]
 east = east[1:*]
 end
