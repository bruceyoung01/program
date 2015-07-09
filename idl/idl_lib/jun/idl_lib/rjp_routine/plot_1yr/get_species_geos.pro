; $Id: get_species_geos.pro,v 1.4 2005/03/10 15:52:14 bmy Exp $
function Get_Species_Geos, FileName,                         $
                      Species=Species, $
                      Verbose=Verbose, Lat=FileLat, $
                      Lon=FileLon, _EXTRA=e

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

   ; Expand FILENAME to a full path name
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
      ;print, 'Longitudes: '
      ;print, FileLon
      ;print, 'Latitudes: '
      ;print, FileLat
      ;print, 'Sigma: '
      ;print, FileSigma
   endif

   ;====================================================================
   ; Read data from the netCDF file
   ; NOTE: dimensions are: [ lon, lat, alt]
   ;====================================================================

   ; Read the SPECIES for the given DATE from the file
   ; NOTE: for now, pull out all lon, lat, lev
   OffSet = [ 0,     0,     0]
   Count  = [ N_Lon, N_Lat, N_Alt]
   Data   = NCDF_Get( fId, species, $
                      OffSet=OffSet, Count=Count, _EXTRA=e )

   NCDF_CLOSE,FId
   ; Return to calling program
   return, Data
end
