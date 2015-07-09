; $Id: make_eur_data.pro,v 1.1.1.1 2007/07/17 20:41:31 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MAKE_EUR_DATA
;
; PURPOSE:
;        Driver program for CREATE_NESTED_DATA.  Hardwired to 
;        the North-America nested-grid of Qinbin Li.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        MAKE_EUR_DATA
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        MFINDFILE         (function)
;        EXTRACT_FILENAME  (function)
;        CREATE_NESTED_MET
;
; REQUIREMENTS:
;
; NOTES:
;        For simplicity, input & output dirs, and X and Y
;        ranges have been hardwired.  Change as necessary.
;
; EXAMPLE:
;        MAKE_EUR_DATA
;
; MODIFICATION HISTORY:
;        bmy, 15 May 2003: VERSION 1.00
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2003-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine make_eur_met"
;-----------------------------------------------------------------------


pro Make_Eur_Data
 
   ;====================================================================
   ; Initialization
   ;====================================================================
   
   ; Input directory
   InDir  = '/pub/ctm/rch/Regrid/'
   OutDir = '~bmy/S/for_isa/'

   ; Lon and lat ranges to trim
   XRange = [ -30, 50 ]
   YRange = [  30, 70 ]

   ; Month array
   Months = [ 'jan', 'feb', 'mar', 'apr', 'may', 'jun',  $
              'jul', 'aug', 'sep', 'oct', 'nov', 'dec' ] 

   ;====================================================================
   ; Process BPCH files
   ;====================================================================
 
   ; Biomass
   InFile  = InDir  + 'bioburn.seasonal.geos3.1x1'
   OutFile = OutDir + 'biomass_200110/bioburn.seasonal.geos3.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; Biofuel
   InFile  = InDir  + 'biofuel.geos.1x1'
   OutFile = OutDir + 'biofuel_200202/biofuel.geos.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange
 
   ; Fossil fuel
   InFile  = InDir  + 'merge_nobiofuels.geos.1x1'
   OutFile = OutDir + 'fossil_200104/merge_nobiofuels.geos.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; C3H8 and C2H6
   InFile  = InDir  + 'C3H8_C2H6_ngas.1x1'
   OutFile = OutDir + 'C3H8_C2H6_200109/C3H8_C2H6_ngas.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; CO loss
   InFile  = InDir  + 'COloss.geos3.1x1'
   OutFile = OutDir + 'pco_lco_200203/COloss.geos3.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; CO prod
   InFile  = InDir  + 'COprod.geos3.1x1'
   OutFile = OutDir + 'pco_lco_200203/COprod.geos3.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; PNOy
   InFile  = InDir  + 'pnoy_nox_hno3.geos3.1x1'
   OutFile = OutDir + 'pnoy_200106/pnoy_nox_hno3.geos3.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange
 
   ; UV-Albedo
   InFile  = InDir  + 'uvalbedo.geos3.2x25'
   OutFile = OutDir + 'uvalbedo_200111/uvalbedo.geos3.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; Strat-JV
   InFile  = InDir  + 'stratjv.geos3.1x1'
   OutFile = OutDir + 'stratjv_200203/stratjv.geos3.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; Strat-OH
   InFile  = InDir  + 'stratOH.geos3.1x1'
   OutFile = OutDir + 'stratOH_200203/stratOH.geos3.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; Scalefoss files (fossil fuel scale factors)
   OutFile = OutDir + 'scalefoss_200203/'
   Create_Nested_Scalefoss, OutDir=OutFile, XRange=XRange, YRange=YRange

   ; Dust files
   OutFile = OutDir + 'dust_200203/'   
   Create_Nested_Dust, OutFile=OutFile, XRange=XRange, YRange=YRange   

   ; Aerosol files
   OutFile = OutDir + 'aerosol_200106/'   
   Create_Nested_Dust, OutFile=OutFile, XRange=XRange, YRange=YRange   

   ; J01D for acetone
   InFile  = InDir  + 'JO1D.geos3.1x1'
   OutFile = OutDir + 'acetone_200108/JO1D.geos.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; Het resp for acetone
   InFile  = InDir  + 'resp.geos3.1x1'
   OutFile = OutDir + 'acetone_200108/resp.geos.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; Ocean acetone for Tagged CO
   InFile = InDir  + 'acetone.geos.1x1'
   OutFile = OutDir + 'tagged_CO__200106/acetone.geos.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; Skip these for now -- we need to regrid sulfate files (bmy, 5/15/03)
goto, next

   ; HNO3.geos3.1x1
   InFile  = InDir  + 'HNO3.geos3.1x1'
   OutFile = OutDir + 'sulfate_sim_200210/HNO3.geos3.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange 

   ; NO3.geos3.1x1
   InFile  = InDir  + 'NO3.geos3.1x1'
   OutFile = OutDir + 'sulfate_sim_200210/NO3.geos3.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange 

   ; O3.geos3.1x1
   InFile  = InDir  + 'O3.geos3.1x1'
   OutFile = OutDir + 'sulfate_sim_200210/O3.geos3.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange 
   
   ; PH2O2.geos3.1x1
   InFile  = InDir  + 'PH2O2.geos3.1x1'
   OutFile = OutDir + 'sulfate_sim_200210/PH2O2.geos3.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange
   

   ; JH2O2.geos3.1x1
   InFile  = InDir  + 'JH2O2.geos3.1x1'
   OutFile = OutDir + 'sulfate_sim_200210/JH2O2.geos3.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange
 
next:

   ;====================================================================
   ; Process ASCII files
   ;====================================================================

   ; Fert-scale 
   InFile  = InDir  + 'fert_scale.dat.geos3.1x1'
   OutFile = OutDir + 'soil_NOx_200203/fert_scale.dat'
   Create_Nested_Ascii, InFile=InFile, OutFile=OutFile, $
                        XRange=XRange, YRange=YRange, Format='(2i6,a)'
   
   ; Soil precip
   InFile  = InDir  + 'climatprep1x1.dat.geos3'
   OutFile = OutDir + 'soil_NOx_200203/climatprep1x1.dat'
   Create_Nested_Ascii, InFile=InFile, OutFile=OutFile, $
                        XRange=XRange, YRange=YRange, Format='(2i3,a)'

   ; Leaf area indices
   for I= 1, 12 do begin
      FileName = 'lai' + String( I, Format='(i2.2)' ) + '.global'
      InFile   = InDir  + FileName
      OutFile  = OutDir + 'leaf_area_index_200202/' + FileName
      Create_Nested_Ascii, InFile=InFile, OutFile=OutFile, $
                           XRange=XRange, YRange=YRange, Format='(2i3,a)'
   endfor

   ; Olson land map -- vegtype.global
   InFile   = InDir  + 'vegtype.global'
   OutFile  = OutDir + 'leaf_area_index_200202/vegtype.global'
   Create_Nested_Ascii, InFile=InFile, OutFile=OutFile, $
                        XRange=XRange, YRange=YRange, Format='(2i4,a)'
   ; Aircraft NOx
   InDir = '/pub/ctm/rch/airnox/'
   File1 = 'air' + Months + '.1x1.fullsize'
   File2 = 'air' + Months + '.1x1'

   for I = 0, 11 do begin
      InFile   = InDir  + File1[I]
      OutFile  = OutDir + 'aircraft_NOx_200202/' + File2[I]
      Create_Nested_Ascii, InFile=InFile, OutFile=OutFile, $
                           XRange=XRange, YRange=YRange, Format='(2i3,a)'
   endfor

   ; Aircraft Fuel (for SOx)
   InDir = '/pub/ctm/rch/airsulf/'
   File1 = 'aircraft.1x1.1992.' + Months + '.fullsize'
   File2 = 'aircraft.1x1.1992.' + Months

   for I = 0, 11 do begin
      InFile   = InDir  + File1[I]
      OutFile  = OutDir + 'sulfate_sim_200210/' + File2[I]
      Create_Nested_Ascii, InFile=InFile, OutFile=OutFile, $
                           XRange=XRange, YRange=YRange,   $
                           Header=2,      Format='(2i4,a)'
   endfor

   ;====================================================================
   ; Return
   ;====================================================================
Quit:
   return
end
