 function month_mean, Dinfo

  jday = Dinfo[0].jday

  Nsite= n_elements(Dinfo)

  jmon = jday2month(jday)

  mm   = jmon(uniq(jmon)) & time=mm
  nmon = n_elements(mm)

  ntag = n_tags(dinfo)
  name = tag_names(dinfo)

  For D = 0, ntag - 1 do begin
      fld = dinfo.(D)
      dim = size(fld)
      if dim[0] eq 1 then newfld = fld else begin
         newfld = fltarr(dim[2],12)

         For N = 0, dim[2]-1L do begin

             For M = 0, nmon  - 1L do begin
                 p = where(jmon eq mm[M])  ; search for the same month

                 if p[0] eq -1 then begin
                    newfld[N, mm[M]-1L] = -999.
                    goto, jump
                 end

                 s = reform(fld[P, N])    ; sample data for the same month
                 p = where(s gt 0.)       ; remove missing data

                 if p[0] eq -1 then begin
                    newfld[N, mm[M]-1L] = -999.
                    goto, jump
                 end

                 newfld[N, mm[M]-1L] = mean(s[p]) ; taking mean

                 jump:
             end
         end
      end

      if D eq 0 then newinfo = create_struct(name[d], newfld) else $
         newinfo = create_struct(newinfo, name[d], newfld)

  end

 return, newinfo

 end
