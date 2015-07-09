;-------------------------------------------------------------
;+
; NAME:
;        CONVERT_KG_MOLCM2 
;
; PURPOSE:
;        Converts the units of a 2-D array from kg to molecules/cm2 
;        (or kg/s to molecules/cm2/s).  
;
; CATEGORY:
;        Unit Conversion 
;
; CALLING SEQUENCE:
;        CONVERT_KG_MOLCM2, DATA, AREACM2, KGPERMOLE
;
; INPUTS:
;        DATA         -> 2-D array of data values in units of
;                        kg or kg s^-1.
;
;        AREACM2      -> 2-D array containing the surface area of each
;                        gridbox in cm^2
;
;        KGPERMOLE    -> The molecular weight of the tracer or
;                        molecule, in units of kg mole^-1.
;
; OUTPUTS:
;        DATA         -> The converted array in molecules cm^-2 s^-1
;                        is returned in DATA. 
;
; KEYWORD PARAMETERS:
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        CTM_SURFACE_AREA must be called to compute the AREACM2 array.
;        TRACER_KG_PER_MOLE (or a similar subroutine) must be called
;        to compute the KGPERMOLE array.
;             
; NOTES:
;
; EXAMPLE:
;        AreaCm2      = CTM_SURFACE_AREA( GridInfo, /cm2, /GEOS )
;        KgPerMole    = TRACER_KG_PER_MOLE( /FULLCHEM )
;        TracerNumber = 1  ; for NOx  
;        CONVERT_KG_MOLCM2, Data, AreaCm2, KgPerMole(TracerNumber)
;
;            Will convert the Data array for the GEOS-1 model (using
;            the molecular weight for NOx) from kg/s to molecules/cm2/s.
;             
; MODIFICATION HISTORY:
;        bmy, 07 Apr 1998: VERSION 1.00
;
;-
; Copyright (C) 1998, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine convert_kg_molcm2"
;-------------------------------------------------------------
pro Convert_Kg_Molcm2, Data, AreaCm2, KgPerMole

   ; Error handling
   on_error, 2

   if ( n_elements( Data ) lt 1 ) then begin
      print, 'The DATA array must have more than 0 elements!'
      stop ; temporary
   endif

   if ( n_elements( AreaCm2 ) lt 1 ) then begin
      print, 'The AreaCm2 array must have more than 0 elements!'
      stop ; temporary
   endif

   if ( n_elements( AreaCm2 ) ne n_elements( Data ) ) then begin
      print, 'The DATA and AREACM2 arrays are not the same size!!'
      stop ; temporary
   endif

   if ( n_elements( KgPerMole ) lt 1 ) then begin
      print, 'KgPerMole must be specified!'
      stop ;temporary
   endif

   ; Number of molecules per mole
   AvogadrosNumber = 6.022e23

   ; Multiply Data by Avogadro's number (molecules/mole) and then
   ; divide by (kg/mole) times surface area.
   Data = Data * ( AvogadrosNumber / ( KgPerMole * AreaCm2 ) )

end
