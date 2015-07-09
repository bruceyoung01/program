 pro writeout, id=id, par=par, poc=poc, time=time, data=data

     mfile = './OUT/'+id+'_PM25_Spec_2004.txt'
     path  = findfile(mfile, count=count)
     if count eq 0L then openw, jl, mfile, /get else return

     spec = aqs_specinfo()
     site = aqs_siteinfo()

     D   = where(site.siteid eq ID)
     C   = where(par gt 0L)

     if D[0] ne -1L then begin
        printf, jl, N_elements(C)+7, format='(I2)'
        printf, jl, N_elements(C)+5, format='(I2)'
        printf, jl, site.siteid[D[0]]
        printf, jl, site.lon[D[0]], format='(f9.4)'
        printf, jl, site.lat[D[0]], format='(f9.4)'
        printf, jl, site.elev[D[0]], format='(f9.4)'
        printf, jl, 'DATE'
        
        for I = 0, N_elements(C)-1 do begin
            sid = where(spec.specid eq par[C[I]])
            printf, jl, spec.name[sid[0]]
        end
        NC = strtrim(N_elements(C),2)

        date = reform(time[*,0])
        NN   = where(date gt 0L)
        date = reform(date[NN])

        for J = 0, N_elements(date)-1L do begin
            samp = reform(data[J,C])
            printf, jl, date[J], samp, format='(i9,'+NC+'f10.4)'
        end        

        ck = where(data[J+1:*,*] gt 0.)
        if ck[0] ne -1L then print, 'something wrong'
     end

     free_lun, jl

  return

 end

;==================================================================
 spec = aqs_specinfo()

 Hd = ' '
 Openr, il, 'RD_501_SPEC_2004.txt', /get

 siteid = 'nul'

 While (not eof(il)) do begin
   readf, il, Hd
   AC = strmid(Hd, 0, 2)
   If AC ne 'RD' then goto, jump

   ID = strmid(Hd,5,2)+strmid(Hd,8,3)+strmid(Hd,12,4)

   mfile = './OUT/'+id+'_PM25_Spec_2004.txt'
   path  = findfile(mfile, count=count)
   if count ne 0L then goto, jump

   array  = csvconvert(Hd, char='|')
   id     = array[2]+array[3]+array[4]
   ipar   = long(array[5])
   ipoc   = long(array[6])
   sdur   = long(array[7])
      sid = where(spec.specid eq ipar)

   ; At least 24-hr sampling
   if sdur eq 7L and ipoc eq 5L and sid[0] gt -1L then begin

      p      = where(siteid eq id)
      ; resetting if site is new
      if p[0] eq -1L then begin

        NID = N_elements(siteid)
        if NID ge 2L then $
        writeout, id=siteid[NID-1L], par=par, poc=poc, time=time, data=data

        siteid = [siteid, id]
        par    = lonarr(100)
        poc    = lonarr(100)
        time   = lonarr(365,100)
        data   = fltarr(365,100)
        I      = -1L
      end

      q      = where(par eq ipar)

      if q[0] eq -1L then begin
         print, id, ipar
         I      = I + 1L
         par[I] = ipar
         poc[I] = ipoc
         D      = 0L
      end

      time[D,I] = long(array[10])
      data[D,I] = float(array[12])
      D         = D + 1L
   endif

   jump:
 Endwhile

 writeout, id=siteid[NID], par=par, poc=poc, time=time, data=data

 Free_lun, il

End
