
  function emep_siteinfo, map=map

  If !D.name eq 'WIN' then $
  file = '.\EMEP\EMEPsites.csv' else $
  file = '/users/ctm/rjp/Data/EMEP/EMEP_sites.csv'

  Openr, Ilun, file, /get

  Hdr = ''
  Code = ''
  Name = ''
  Lat  = 0.
  Lon  = 0.
  Elev = 0.

  Readf, Ilun, Hdr
  Readf, Ilun, Hdr

  while ( not eof(Ilun) ) do begin
   Readf, Ilun, Hdr
   TAG = csvconvert(Hdr)

   Code = [Code, TAG[0]]
   Name = [Name, TAG[1]]

   ; Lat/Lon unit is 
   ; Angular measurement must be used in addition to simple plane geometry to specify location on the earth's surface. 
   ; This is based on a sexagesimal scale: 
   ; A circle has 360 degrees, 60 minutes per degree, and 60 seconds per minute. 
   ; There are 3,600 seconds per degree. 
   ; Example: 45o 33' 22" (45 degrees, 33 minutes, 22 seconds). 
   ; It is often necessary to convert this conventional angular measurement into decimal degrees. 
   ; To convert 45o 33' 22", first multiply 33 minutes by 60, which equals 1,980 seconds. 
   ; Next add 22 seconds to 1,980: 2,002 total seconds. 
   ; Now compute the ratio: 2,002/3,600 = 0.55. 
   ; Adding this to 45 degrees, the answer is 45.55o 

   Rlat = float(TAG[2])+(float(TAG[3])*60.+float(TAG[4]))/3600.
   If TAG[5] eq 'S' then sign = -1. else sign = 1.
   Lat  = [Lat, sign*Rlat]

   Rlon = float(TAG[6])+(float(TAG[7])*60.+float(TAG[8]))/3600.
   If TAG[9] eq 'W' then sign = -1. else sign = 1.
   Lon  = [Lon, sign*Rlon]

   Alt  = float(TAG[10])
   Elev = [Elev, Alt]

  end

  Free_lun, Ilun

  Info = {code:code[1:*], $
          name:name[1:*], $
          lat :lat[1:*],  $
          lon :lon[1:*],  $
          elev:elev[1:*]}

  If keyword_set(map) then begin
    map_set, 0, 0, color=1, limit=[20.,-20.,80.,50.]
    map_continents, /coasts, color=1, /countries
    for i = 0, N_elements(Info.code)-1 do $ 
     xyouts, info.lon(i), info.lat(i), '*', color=1, $
     charsize=1.0, charthick=4.0, alignment=0.5
  Endif

  return, Info   

 end

;=============================================================================

 function emep_datainfo, year=year

  if n_elements(year) eq 0 then year = 1998L


  if !D.name eq 'WIN' then $
   DIR = 'EMEP\' else $
   DIR = '/users/ctm/rjp/Data/EMEP/'

; getting EMEP mesurement site information
   info = emep_siteinfo()

   file = DIR+'emep_monthly-data_'+strtrim(year,2)+'.dat'

   Hdr = ''
   Spec= ''
   Site= ''
   Lat = 0.
   Lon = 0.
   Alt = 0.
   Name= ''

   Data= 0.
   st_f = 0L
   sp_f = 0L
   icount=0L

   Openr, Ilun, file, /get

   While (not eof(ilun)) do begin

      readf, ilun, Hdr

      Tag = csvconvert(Hdr)
      pos = where(TAG[0] eq info.code)
      if pos[0] eq -1 then goto, jump  ; skip data if no information
      Icount = icount + 1L

      chk = where(TAG[0] eq Site)
      if chk[0] eq -1 then begin
         Site = [Site, info.code[pos[0]]]
         Lat  = [Lat, info.lat[pos[0]]]
         Lon  = [Lon, info.lon[pos[0]]]
         Name = [Name,info.name[pos[0]]]
         Alt  = [Alt, info.elev[pos[0]]]
         chk  = where(TAG[0] eq SITE)
         i_st = chk[0] - 1L
      end else i_st = chk[0] -1L

      t_ch= exchar(TAG[1]+'_'+TAG[2], '+', '_')
      pk  = where(t_ch eq SPEC)
      if pk[0] eq -1 then begin
         SPEC = [SPEC, t_ch]
         pk= WHERE(t_ch eq SPEC) 
         I_SP = pk[0] - 1L
      end else I_SP = pk[0] -1L

      st_f = [st_f, i_st]
      sp_f = [sp_f, i_sp]
      Data = [Data, float(Tag[4:15])]
    jump:
   end

   Spec = Spec[1:*]
   st_f = st_f[1:*]
   sp_f = sp_f[1:*]

   Data = Reform(Data[1:*], 12, Icount)
   Newdata = Fltarr(N_elements(Site[1:*]), 12, N_elements(Spec))
   
   For D = 0, Icount-1L do begin
       I = st_f[D]
       J = sp_f[D]
       Newdata[I,*,J] = Data[*,D]
   End
       

   result = create_struct('siteid', Site[1:*], 'lat', lat[1:*],  $
             'lon', lon[1:*], 'elev',Alt[1:*], 'name',name[1:*])

   for D = 0, N_elements(spec)-1 do  $
       result = create_struct(result,spec[D],reform(newdata[*,*,D]))
            
  return, result

 end
