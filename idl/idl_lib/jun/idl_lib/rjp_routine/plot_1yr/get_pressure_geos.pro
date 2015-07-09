; $Id: get_pressure_geos.pro,v 1.3 2004/03/29 16:30:47 bmy Exp $
function Get_Pressure_Geos, FileName, PTOP=PTOP,$
                       Verbose=Verbose, $
                       Lat=FileLat, Lon=FileLon, $
                       _EXTRA=e

   ;====================================================================
   ; Keywords / External functions
   ;====================================================================
   FORWARD_FUNCTION NCDF_Get

   if ( N_Elements( FileName ) ne 1 ) then Message, 'FILENAME not passed!'
   Verbose = Keyword_Set( Verbose )

   ;====================================================================
   ; Read Header and Index information from the netCDF file
   ;====================================================================

   ; Define flags
   IsSigma   = 0
   IsEta     = 0

   ; Expand filename to full path name
   FileName  = Expand_Path( FileName )

   ; Open file
   fId       = NCDF_Open( FileName )

   ; Test if we have ETA coordinates or SIGMA coordinates (bmy, 3/29/04)
   NStru = NCDF_Inquire( fId )

   ; Loop over netCDF variables
   for N = 0L, NStru.NVars-1L do begin
      VarDesc = NCDF_VarInq( fId, N )
     
      ; We have sigma grid
      if ( StrTrim( VarDesc.Name ) eq 'SIGC' ) then begin
         IsSigma = 1
         goto, Next
      endif

      if ( StrTrim( VarDesc.Name ) eq 'ETAC' ) then begin
         IsEta = 1
         goto, Next
      endif
   endfor

Next:

   ; Read LONGITUDE from file
   FileLon   = NCDF_Get( fId, 'LON' )
   N_Lon     = N_Elements( FileLon )

   ; Read LATITUDE from file
   FileLat   = NCDF_Get( fId, 'LAT' )
   N_Lat     = N_Elements( FileLat )

   ; Read SIGMA from file
   if ( IsSigma ) then begin
      FileSigma = NCDF_Get( fId, 'SIGC' )
      N_Alt     = N_Elements( FileSigma )
   endif 

   ; Read ETA from file
   if ( IsEta ) then begin
      FileSigma = NCDF_Get( fId, 'ETAC' )
      N_Alt     = N_Elements( FileSigma )
   endif

   ; If /VERBOSE is set, then print out quantities
   if ( Verbose ) then begin
      ;print, 'Longitudes in file '
      ;print, FileLon
      ;print, 'Latitudes in file '
      ;print, FileLat
      ;print, 'Sigma levels in file '
      ;print, FileSigma
   endif

   ;====================================================================
   ; Read surface pressure from the netCDF file
   ; NOTE: dimensions are: [ lon, lat]
   ;====================================================================

   ; INDD = location of DATE w/in the FILEDATES dimension
   IndD = 0

   ; Read the SURFACE PRESSURE for the given DATE from the file
   ; NOTE: for now, pull out all lon, lat
   OffSet = [ 0,     0,     IndD[0] ]

   Count  = [ N_Lon, N_Lat,1]
;   Psurf  = NCDF_Get( fId, 'PS-PTOP::PSURF',   $
;                      OffSet=OffSet, Count=Count, _EXTRA=e )

   Psurf  = NCDF_Get( fId, 'PS-PTOP::PSURF')

   ; Close file
   NCDF_Close, fId

   ;====================================================================
   ; Compute pressure at each vertical level, using the formula
   ;====================================================================

   ; Pressure array
   Pressure = FltArr( N_Lon, N_Lat, N_Alt )

   ; Formula for real pressure     pressure= (psurf-ptop) * sigma + ptop
   for L = 0L, N_Alt-1L do begin
   for j = 0L, N_Lat-1L do begin
   for i = 0L, N_Lon-1L do begin
      Pressure[I,J,L] = FileSigma[L]* psurf[I,J,0]+PTOP 
   endfor
   endfor
   endfor
   ; Return to calling program
   return, Pressure

end
