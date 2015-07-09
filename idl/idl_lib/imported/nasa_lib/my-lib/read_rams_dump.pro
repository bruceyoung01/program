
;read dump file from RAMS 
pro read_rams_dump, inpf, ttime, aotv, height,nt, nz0, varname, np, nl
   nouse1 = ' '
   nouse2 = ' '
   tmptime = 1.0D
   nz = 0L
   
   
   nzmax=20  ; true layers. note nz0 is how many layers we want to  extract 
   if ( varname eq 'GEO' ) then nzmax = 11 ; for geopotential, only 11   layers

   if ( varname eq 'LAT' or varname eq 'LON' or $
        varname eq 'PBL' or varname eq 'TOPO' or $
	varname eq 'RSHORT' or varname eq 'ALBEDO' or $
	varname eq 'CLDFRAC') then nzmax = 1 
   
   nt = 0L
;   np = 5
;   nl = 3
   tmpvar = fltarr(np, nl)
   timev = dblarr( 1000,nz0)
   aotv = dblarr(np, nl,1000,nz0)
   heightv = fltarr(1000, nz0)
   
   print, 'varname = ', varname
   
   openr, 1, inpf
   while not eof(1) and nt le 1000 do begin
   
   if (  strcmp(varname, 'MASS',3) ) then begin
   readf, 1,  tmph,tmptime,  format = '(25x, f11.2, f11.0)'
   ;print, tmph, tmptime 
   endif
   
   if ( varname eq 'AOT'  ) then begin
   readf, 1,  tmph,tmptime,  format = '(19x, f11.2, f11.0)'
   ;print, tmph, tmptime 
   endif
   
   if ( varname eq 'rh' ) then begin
   readf, 1,  tmph,  tmptime, format = '(35x, f11.2, f11.0)'
   endif
   
   if ( varname eq 'GEO' ) then begin
   readf, 1,  tmph,  tmptime, format = '(35x, f7.0, f11.0)'
   endif
   
   
   if ( varname eq 'TEMP' ) then begin
   readf, 1,  tmph,  tmptime, format = '(28x, f11.2, f10.0)'
   endif

   if ( varname eq 'PBL' ) then begin
   readf, 1,  tmph,  tmptime, format = '(26x, f11.2, f10.2)'
   endif
   
   if ( varname eq 'RSHORT' ) then begin
   readf, 1,  tmph,  tmptime, format = '(25x, f11.2, f10.2)'
   endif
   
   if ( varname eq 'RLONG' ) then begin
   readf, 1,  tmph,  tmptime, format = '(25x, f11.2, f11.0)'
   endif

   if ( varname eq 'ALBEDO' ) then begin
   readf, 1,  tmph,  tmptime, format = '(23x, f11.2, f11.0)'
   endif

   if ( varname eq 'LAT' ) then begin
   readf, 1,  tmph,  tmptime, format = '(27x, f11.2, f11.0)'
   endif

   if ( varname eq 'LON' ) then begin
   readf, 1,  tmph,  tmptime, format = '(27x, f11.2, f11.0)'
   endif

   if ( varname eq 'TKE' ) then begin
   readf, 1,  tmph,  tmptime, format = '(39x, f11.2, f11.0)'
   endif


   if ( varname eq 'TOPO' ) then begin
   readf, 1,  tmph,  tmptime, format = '(20x, f11.2, f10.2)'
   endif

   if ( varname eq 'CLDFRAC' ) then begin
   readf, 1,  tmph,  tmptime, format = '(30x, f11.2, f10.2)'
   endif
   
;   timev(nt,nz) = tmptime
;   heightv(nt, nz)= tmph

  ; for k = 0, nl-1 do begin
      readf, 1,  tmpvar
      if ( nz lt nz0 ) then begin
       timev(nt,nz) = tmptime
       heightv(nt, nz)= tmph
       aotv(0:np-1, 0:nl-1, nt,nz) = tmpvar(0:np-1, 0:nl-1)
      endif

  ; endfor 
   
   nz= nz+1
 ;  print, tmph, tmptime

   if ( nz mod nzmax eq 0 ) then begin
         nt = nt +1
	 nz = 0
   endif

 endwhile
  close,1

  tmpvar = 0.0
  ttime  = temporary(timev(0:nt-1, 0:nz0-1))
  timev = 0.0
  aotv = temporary(aotv(0:np-1, 0:nl-1, 0:nt-1, 0:nz0-1))
;  aotv = 0.0
  height = heightv(0:nt-1, 0:nz0-1)
  heightv = 0.0
 print, 'nz=', nz, 'nt = ', nt , 'nz0 = ', nz0
end   	
