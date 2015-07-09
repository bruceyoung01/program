; $Id: convert_molcm2_kg.pro,v 1.1.1.1 2003/10/22 18:06:04 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CONVERT_MOLCM2_KG 
;
; PURPOSE:
;        Converts the units of a 2-D or 3-D array from molecules/cm2 
;        to kg (or, equivalently, from molecules/cm2/s to kg/s).  
;
; CATEGORY:
;        Unit Conversion 
;
; CALLING SEQUENCE:
;        CONVERT_MOLCM2_KG, DATA, AREACM2, KGPERMOLE
;
; INPUTS:
;        DATA         -> 2-D or 3-D array of data values in units of
;                        molecules cm^-2 or molecules cm^-2 s^-1.
;
;        AREACM2      -> 2-D array containing the surface area of each
;                        gridbox in cm^2
;
;        KGPERMOLE    -> The molecular weight of the tracer or
;                        molecule, in units of kg/mole.
; 
; OUTPUTS:
;        DATA         -> The converted array in kg/s is returned in DATA. 
;                        DATA is returned with the same dimensions as
;                        it had when it was passed to CONVERT_MOLCM2_KG.
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
;        TracerNumber = 1   ; for NOx
;        CONVERT_MOLCM2_KG, Data, AreaCm2, KgPerMole
;
;            Will convert the Data array for the GEOS-1 model (using
;            the molecular weight for NOx) from molecules/cm2/s to kg/s.
;             
;
; MODIFICATION HISTORY:
;        bmy, 07 Apr 1998: VERSION 1.00
;        bmy, 09 Apr 1998: VERSION 1.01 
;                          - DATA can now be a 2-D or 3-D array.
;                          - KgPerMole can now be an array of the same
;                            dimension as the 3rd dimension of Data.
;        bmy, 07 Oct 1998: VERSION 1.02
;                          - now uses MESSAGE statement
;                          - also uses [] instead of () for array
;                            indices
;        bmy  23 Nov 1998: VERSION 2.00
;                          - now uses double precision array NEWDATA
;                            to avoid overflow/underflow errors
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
; with subject "IDL routine convert_molcm2_kg"
;-------------------------------------------------------------

pro Convert_MolCm2_Kg, Data, AreaCm2, KgPerMole

   ;========================================================
   ; Determine the dimensions of Data and AreaCm2 arrays. 
   ;========================================================
   SD = size( Data      )
   SA = size( AreaCm2   )
   SK = size( KgPerMole )

   ;==============================================================
   ; Make sure the 1st-dimension of DATA matches that of AREACM2
   ;==============================================================
   if ( SD[1] ne SA[1] ) then begin
      Message, '1st-dimensions of Data and AreaCm2 are not the same!', /Cont
      print,   '            1st-dim of Data:    ', SD(1)
      print,   '            1st-dim of AreaCm2: ', SA(1)
      return  
   endif

   ;==============================================================
   ; Make sure the 2nd-dimension of DATA matches that of AREACM2
   ;==============================================================
   if ( SD[2] ne SA[2] ) then begin
      Message, '2nd-dimensions of Data and AreaCm2 are not the same!'
      print,   '            2nd-dim of Data:    ', SD(2)
      print,   '            2nd-dim of AreaCm2: ', SA(2)
      return   
   endif

   ;=============================================================
   ; Introduce the NEWDATA array, of double precision (so as to 
   ; avoid overflow errors).  Make sure NEWDATA is always 3-D.  
   ; If DATA is only 2-D then introduce a "fake" 3rd dimension 
   ; to NEWDATA for purposes of looping.  
   ;=============================================================
   NewData = Double( Data )
   if ( SD[0] eq 2 ) then NewData = Reform( NewData, SD[1], SD[2], 1 ) 
   SD = Size( NewData )

   ;=============================================================   
   ; If KGPERMOLE is only a scalar, then turn it into an array 
   ; of dimension 1, in order to match the 3rd dimension of 
   ; NEWDATA, for looping purposes.   
   ;=============================================================   
   if ( SK[0] eq 0 ) then begin
      KgPerMole = Replicate( KgPerMole, 1 )
      SK        = Size( KgPerMole )
   endif

   ;=============================================================   
   ; Check to make sure that the dimension of KGPERMOLE matches
   ; the 3rd dimension of NEWDATA
   ;=============================================================   
   if ( SK[1] ne SD[3] ) then begin
      Message, 'KgPerMole does not match the 3rd dimension of Data!!!',  /Cont
      print,   '            3rd Dim of Data:    ', SD(3)
      print,   '            Dim     of AreaCm2: ', SK(1)
      return 
   endif

   ;================================
   ; Number of molecules per mole
   ;================================
   AvogadrosNumber = 6.022d23

   ;================================
   ; Do the unit conversion!!!
   ;================================
   for I = 0, SD[3] - 1 do begin
      NewData[*, *, I] = NewData[*, *, I] * AreaCm2 * $
                         ( KgPerMole[I] / AvogadrosNumber )
   endfor
      
   ;=====================================================
   ; If the third dimension equals 1, then return DATA 
   ; to a 2-D array and return KgPerMole to a scalar.
   ; Also return DATA to a floating point array.
   ;=====================================================
   Data = Float( NewData )

   if ( SD[3] eq 1 ) then begin
      Data      = Reform( Data, SD[1], SD[2] )
      KgPerMole = KgPerMole[0]
   endif

end
