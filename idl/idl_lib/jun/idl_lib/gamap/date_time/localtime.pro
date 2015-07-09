; $Id: localtime.pro,v 1.1 2007/07/30 16:14:11 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        LOCALTIME
;
; PURPOSE:
;        Returns the local time at a particular location, given the
;        Universal Time (aka Greenwich Time) and longitude.
;
; CATEGORY:
;        Date & Time
;
; CALLING SEQUENCE:
;        RESULT = LOCALTIME( UTC, LON )
;
; INPUTS:
;        UTC -> Universal Time (aka Greenwich Time) in hours.
;             UTC may be either a scalar or a vector.
;
;        LON -> Longitude in degrees.  LON may be in the range
;             -180..180 or 0..360.  LON may be either a scalar
;             or a vector.
;
; KEYWORD PARAMETERS:
;        /DOUBLE -> Set this switch to return local time in
;             double precision.  Default is to return local time
;             in single precision.
;            
; OUTPUTS:
;        RESULT -> The local time corresponding to UTC and LON.
;             If UTC and LON are vectors, then RESULT will also
;             be a vector of local times.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLES:
;        (1)
;        PRINT, LOCALTIME( 0, -71.06 )
;          19.2627
;
;             ; Returns the local time (approx 19.26 decimal, which
;             ; is approx 19:15 PM) at Boston (lon=71.06W) when
;             ; it is 00:00 UTC.
;
;        (2)
;        PRINT, LOCALTIME( 0, -71.06, /DOUBLE )
;          19.262667
;
;             ; Same as Example (1), but returns local time
;             ; as double precision.
; 
;        (3) 
;        PRINT, LOCALTIME( [0,1,2], -71.06, /DOUBLE )
;             19.262667   20.262667   21.262667
;
;             ; Returns the local times at Boston (as in 
;             ; Examples (1) and (2)) when it is 00:00, 01:00,
;             ; and 02:00 UTC time.
;
; MODIFICATION HISTORY:
;        dbm, 30 Jul 2007: VERSION 1.00
;
;-
; Copyright (C) 2007, Dylan Millet,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine localtime"
;-----------------------------------------------------------------------


function LocalTime, UTC, Lon, Double=Double
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; Return to calling routine on error
   On_Error, 2

   ; Check UTC
   if ( Min( UTC, Max=M ) lt 0 OR M gt 24 ) then begin 
      Message,  'UTC must be in the range 0-24 hours!', /Info
      return, -1
   endif

   ; Check LON
   if ( Min( Lon, Max=M ) lt -180 OR M gt 360 ) then begin
      Message, 'LON must be in the range -180..180 or 0..360!', /Info
      return, -1
   endif
 
   ; Copy LON to temporary variable TMPLON
   TmpLon = Lon

   ; Convert longitudes 
   Ind = Where( TmpLon gt 180 )
   If ( Ind[0] ge 0 ) then TmpLon[Ind] = TmpLon[Ind] - 360.0

   ;====================================================================
   ; Computation
   ;====================================================================

   ; Local Time = UTC + ( longitude / 15 ) since each hour of time
   ; corresponds to 15 degrees of longitude on the globe  
   LocTime = Double( UTC ) + ( Double( TmpLon ) / 15d0 )
 
   ; make sure localtime is in the range 0-24 hours
   Ind = Where( LocTime gt 24d0 )
   if ( Ind[0] ge 0 ) then LocTime[Ind] = LocTime[Ind] - 24d0

   Ind = Where( LocTime lt 0d0 ) 
   if ( Ind[0] ge 0 ) then LocTime[Ind] = LocTime[Ind] + 24d0
 
   ; Return local time
   if ( Keyword_Set( Double ) )    $
      then return, LocTime         $
      else return, Float( LocTime )
 
end
 
