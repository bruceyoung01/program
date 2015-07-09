
 function daily2monthly, data, jday, Undef=Undef

  if n_elements(Undef) eq 0 then Undef = '-999.'

  jmon = jday2month(jday)

  mm   = jmon(uniq(jmon)) & time=mm
  nmon = n_elements(mm)

  avg  = fltarr(12) ; 12 month

  For M = 0, nmon  - 1L do begin
      p = where(jmon eq mm[M])  ; search for the same month
      
      if p[0] eq -1 then begin
          avg[mm[M]-1L] = Undef
          goto, jump
      end

      s = reform(data[P])                       ; sample data for the same month
      p = where(s gt 0. and finite(s) eq 1)     ; remove missing data

      if p[0] eq -1 then begin
         avg[mm[M]-1L] = Undef
         goto, jump
      end

      if n_elements(p) eq 1 then avg[mm[M]-1] = s[p[0]] else $
      avg[mm[M]-1L] = mean(s[p]) ; taking mean

      jump:
  end


 return, avg

 end
