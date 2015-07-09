 function read_amp500

 Hd = ' '
 Openr, il, 'AMP500_1994_FEB_05-1.txt', /get
 siteid = 'nul'
 lat    = 0.
 lon    = 0.
 alt    = 0.
 
 While (not eof(il)) do begin
   readf, il, Hd
   AC = strmid(Hd, 0, 2)

   If AC eq 'AA' and N_elements(str) ne 0L then begin
      str = create_struct(str, 'parameter',par, 'poc',poc)
      if N_elements(s_array) eq 0L then s_array = str else s_array = [s_array, str]
   end

   CASE AC of 
     'AA' : begin
            array  = csvconvert(Hd, char='|')
            siteid = array[2]+array[3]+array[4]
            lat    = float(array[5])       ; in degree
            lon    = float(array[6])       ; in degree
            alt    = float(array[14])      ; in meter
            str    = create_struct('siteid',siteid, 'lat',lat, 'lon',lon, 'alt',alt, $
                                   'addr',array[17])
            par    = lonarr(100)
            poc    = par
            I      = 0L
            print, siteid
            end

     'MC' : begin
            array  = csvconvert(Hd, char='|')
            if array[7] eq 'SLAMS SPECIATION' or array[7] eq 'TRENDS SPECIATION' then begin
               T = Long(array[5])
               p = where(par eq T)
               
               if p[0] eq -1L and T ge 88101L then begin
                  par[I] = Long(array[5])
                  poc[I] = Long(array[6])
                  I      = I + 1L
               end
            endif
            end

     else : 
   ENDCASE

 Endwhile

 Free_lun, il

 return, s_array

End


 if N_elements(str) eq 0 then str = read_amp500()

 Openw, il, 'epa_aqs_siteinfo.txt', /get

 For D = 0, N_elements(str)-1 do begin
   t = str[D].poc
   p = where(t eq 5L)
   if p[0] ne -1L then $
      printf, il, str[D].siteid, str[D].lat, str[D].lon, str[D].alt, strtrim(str[D].addr,2), $
      format='(A10,3F10.4,3X,A50)'
 End

 free_lun, il

 End
