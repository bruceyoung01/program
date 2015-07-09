function improve_frh, rh

 if n_elements(rh) eq 0 then return, -1

 RH_d  = fltarr(98)
 fRH_d = fltarr(98)

 Openr, il, '/users/ctm/rjp/Data/IDL/frh_table.dat', /get

 HD = ' '
 readf, il, HD
 a = 0.
 b = 0.

 For N = 0, 97 do begin
   readf, il, a , b
   RH_d[N] = a
   fRH_d[N] = b
 End

 free_lun, il

 frh = rh

 For D = 0L, Long(N_elements(rh))-1L do begin

;    rh_in = (float(round(rh[D])) < 95.) > 1.
;    p = where(rh_in eq RH_d)

    rh_in = (rh[D] <= 95.) > 1.
    p = locate(rh_in, RH_d, cof=cof)

    if p[0] eq -1 then begin
      print, 'no match found!!'
      return, -1
    end

;    frh[D] = frh_d[p[0]]
    frh[D] = (frh_d[p[0]+1]-frh_d[p[0]])*cof + frh_d[p[0]]

 Endfor

 return, frh

 End
