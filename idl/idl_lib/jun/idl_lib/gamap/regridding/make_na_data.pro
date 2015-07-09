; $Id: make_na_data.pro,v 1.1.1.1 2007/07/17 20:41:30 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MAKE_NA_DATA
;
; PURPOSE:
;        Driver program for CREATE_NESTED_DATA.  Hardwired to 
;        the North-America nested-grid of Qinbin Li.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        MAKE_NA_DATA
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
;        None
;
; NOTES:
;        For simplicity, input & output dirs, and X and Y
;        ranges have been hardwired.  Change as necessary.
;
; EXAMPLE:
;        MAKE_NA_MET
;
; MODIFICATION HISTORY:
;        bmy, 10 Apr 2003: VERSION 1.00
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
; or phs@io.as.harvard.edu with subject "IDL routine make_na_data"
;-----------------------------------------------------------------------


pro Make_NA_Data
 
   ;====================================================================
   ; Initialization
   ;====================================================================
   
   ; Input directory (add more as necessary)
   ;InDir  = '~/S/'
   InDir  = '~/archive/data/sulfate_sim_200210/1x1_geos/'
   ;InDir  = '~/archive/data/biomass_200110/1x1_geos/'
   ;InDir = '~tmf/avhrrlai_2000/1x1/'
   ;OutDir = '/data/ctm/GEOS_1x1_NA/'
   OutDir  = '~/archive/data/sulfate_sim_200210/1x1_geos_na/'

   ; Lon and lat ranges to trim
   XRange = [ -140, -40 ]
   YRange = [   10,  60 ]

   ; Month name array
   Months   = [ 'jan', 'feb', 'mar', 'apr', 'may', 'jun',  $
                'jul', 'aug', 'sep', 'oct', 'nov', 'dec' ] 
  
   ; Month number array
   MonthNum = [ '01', '02', '03', '04', '05', '06', $
                '07', '08', '09', '10', '11', '12' ]

   ;====================================================================
   ; Process BPCH files
   ;====================================================================
 
   ; skip over files we have done already
goto, next

   ;---------------------
   ; Emissions files
   ;---------------------

   ; Biomass
   InFile  = InDir  + 'bioburn.interannual.geos.1x1.2001'
   OutFile = OutDir + 'biomass_200110/' + Extract_Filename( InFile )
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

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

   ;---------------------
   ; EPA/NEI emissions
   ;---------------------
   for M = 0, 11 do begin

      ; Weekday anthro files
      InFile  = InDir  + 'wkday_avg_an.1999' + MonthNum[M] + '.geos.1x1'
      OutFile = OutDir + 'EPA_NEI_200411/' + Extract_Filename( InFile )
      Create_Nested, InFile=InFile, OutFile=OutFile, $
                     XRange=XRange, YRange=YRange

      ; Weekend anthro files
      InFile  = InDir  + 'wkend_avg_an.1999' + MonthNum[M] + '.geos.1x1'
      OutFile = OutDir + 'EPA_NEI_200411/' + Extract_Filename( InFile )
      Create_Nested, InFile=InFile, OutFile=OutFile, $
                     XRange=XRange, YRange=YRange

      ; Weekday biofuel files
      InFile  = InDir  + 'wkday_avg_bf.1999' + MonthNum[M] + '.geos.1x1'
      OutFile = OutDir + 'EPA_NEI_200411/' + Extract_Filename( InFile )
      Create_Nested, InFile=InFile, OutFile=OutFile, $
                     XRange=XRange, YRange=YRange

      ; Weekend biofuel files
      InFile  = InDir  + 'wkend_avg_bf.1999' + MonthNum[M] + '.geos.1x1'
      OutFile = OutDir + 'EPA_NEI_200411/' + Extract_Filename( InFile )
      Create_Nested, InFile=InFile, OutFile=OutFile, $
                     XRange=XRange, YRange=YRange
   endfor

   ; USA Mask file for EPA/NEI emissions
   InFile  = InDir  + 'usa_mask.geos.1x1'
   OutFile = OutDir + 'EPA_NEI_200411/' + Extract_Filename( InFile )
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ;---------------------
   ; P/L strat files
   ;---------------------

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

   ;---------------------
   ; Other files
   ;---------------------

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

   ; Strat-OH
   ;InFile  = '/pub/ctm/rch/stratOH.geos3.1x1'
   InFile  = '~/S/stratOH.geos3.1x1'
   OutFile = OutDir + 'stratOH_200203/stratOH.geos3.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; Scalefoss files (fossil fuel scale factors)
   OutFile = OutDir + 'scalefoss_200202/'
   Create_Nested_Scalefoss, OutDir=OutFile, XRange=XRange, YRange=YRange

   ;---------------------
   ; Acetone files
   ;---------------------

   ; J01D for acetone
   InFile  = '/pub/ctm/rch/JO1D.geos.1x1'
   OutFile = OutDir + 'acetone_200108/JO1D.geos3.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; Het resp for acetone
   InFile  = '/pub/ctm/rch/resp.geos.1x1'
   OutFile = OutDir + 'acetone_200108/resp.geos3.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; Ocean acetone for Tagged CO
   InFile  = '/pub/ctm/rch/acetone.geos.1x1'
   OutFile = OutDir + 'tagged_CO_200106/acetone.geos.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ;----------------------
   ; Sulfate Sim files
   ;----------------------

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

   ; shipSOx.geos.1x1
   InFile  = InDir  + 'shipSOx.geos.1x1'
   OutFile = OutDir + 'sulfate_sim_200210/' + Extract_FileName( InFile )
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange 

Next:
   ; scalefoss.SOx.1x1.2002
   InFile  = InDir  + 'scalefoss.SOx.1x1.2002'
   OutFile = OutDir + Extract_FileName( InFile )
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange
return

   ;---------------------
   ; Offline aerosols
   ;---------------------

   ; Aerosol files
   OutFile = OutDir + 'aerosol_200106/'   
   Create_Nested_Dust, OutFile=OutFile, XRange=XRange, YRange=YRange   

   ;----------------------
   ; Carbon aerosol files
   ;----------------------

   Infile  = InDir  + 'BCOC_TBond_biofuel.geos.1x1'
   OutFile = OutDir + 'carbon_200411/' + Extract_FileName( InFile )
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   Infile  = Indir  + 'BCOC_TBond_biomass.geos.1x1'
   OutFile = OutDir + 'carbon_200411/' + Extract_FileName( InFile )
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   Infile  = InDir  + 'BCOC_TBond_fossil.geos.1x1'
   OutFile = OutDir + 'carbon_200411/' + Extract_FileName( InFile )
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   Infile  = InDir  + 'BCOC_anthsrce.geos.1x1'
   OutFile = OutDir + 'carbon_200411/' + Extract_FileName( InFile )
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   Infile  = InDir  + 'BCOC_biofuel.geos.1x1'
   OutFile = OutDir + 'carbon_200411/' + Extract_FileName( InFile )
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   Infile  = InDir  + 'NH3_anthsrce.geos.1x1'
   OutFile = OutDir + 'carbon_200411/' + Extract_FileName( InFile )
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   Infile  = InDir  + 'NH3_biofuel.geos.1x1'
   OutFile = OutDir + 'carbon_200411/' + Extract_FileName( InFile )
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   Infile  = InDir  + 'NH3_natusrce.geos.1x1'
   OutFile = OutDir + 'carbon_200411/' + Extract_FileName( InFile )
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   Infile = InDir   + 'NVOC.geos.1x1'
   OutFile = OutDir + 'carbon_200411/' + Extract_FileName( InFile )
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   Infile = InDir   + 'aer.bioburn.interannual.geos.1x1.2001'
   OutFile = OutDir + 'carbon_200411/' + Extract_FileName( InFile )
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   Infile = InDir   + 'emis_fac.EC-OC.1x1'
   OutFile = OutDir + 'carbon_200411/' + Extract_FileName( InFile )
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ;---------------------
   ; Dust aerosol files
   ;---------------------

   ; Dust files
   OutFile = OutDir + 'dust_200203/'   
   Create_Nested_Dust, OutFile=OutFile, XRange=XRange, YRange=YRange   

   ; DEAD dust files -- invariant quantities
   InFile  = '~/S/dst_tibds_1x1.bpch'
   OutFile = OutDir + 'dust_200203/dst_tibds.geos.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; DEAD dust files -- time varying quantities
   InFile  = '~/S/dst_tvbds_1x1.bpch'
   OutFile = OutDir + 'dust_200203/dst_tvbds.geos.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

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
      OutFile  = OutDir + 'leaf_area_index_200412/' + FileName
      Create_Nested_Ascii, InFile=InFile, OutFile=OutFile, $
                           XRange=XRange, YRange=YRange, Format='(2i3,a)'
   endfor

   ; Olson land map -- vegtype.global
   InFile   = InDir  + 'vegtype.global'
   OutFile  = OutDir + 'leaf_area_index_200412/vegtype.global'
   Create_Nested_Ascii, InFile=InFile, OutFile=OutFile, $
                        XRange=XRange, YRange=YRange, Format='(2i4,a)'

   ; Aircraft NOx
   File1 = 'air' + Months + '.1x1.fullsize'
   File2 = 'air' + Months + '.1x1'

   for I = 0, 11 do begin
      InFile   = InDir  + File1[I]
      OutFile  = OutDir + 'aircraft_NOx_200202/' + File2[I]
      Create_Nested_Ascii, InFile=InFile, OutFile=OutFile, $
                           XRange=XRange, YRange=YRange, Format='(2i3,a)'
   endfor

   ; Aircraft Fuel (for SOx)
   File1 = 'aircraft.1x1.1992.' + Months + '.fullsize'
   File2 = 'aircraft.1x1.1992.' + Months

   for I = 0, 11 do begin
      InFile   = InDir  + File1[I]
      OutFile  = OutDir + 'sulfate_sim_200210/' + File2[I]
      Create_Nested_Ascii, InFile=InFile, OutFile=OutFile, $
                           XRange=XRange, YRange=YRange,   $
                           Header=2,      Format='(2i4,a)'
   endfor

   ;-----------------------
   ; Aerosol biomass files
   ;-----------------------

   Years   = [ '2000', '2001', '2002' ]

   ; Interannual
   InFile1  = InDir  + 'SO2.bioburn.interannual.geos.1x1.'  + Years
   InFile2  = InDir  + 'NH3.bioburn.interannual.geos.1x1.'  + Years
   InFile3  = InDir  + 'BCPO.bioburn.interannual.geos.1x1.' + Years
   InFile4  = InDir  + 'OCPO.bioburn.interannual.geos.1x1.' + Years

   ; Loop over years
   for Y=0L, N_Elements( Years )-1L do begin

      ; SO2 
      OutFile = OutDir + 'biomass_200110/' + Extract_Filename( InFile1[Y] )
      Create_Nested, InFile=InFile1[Y], OutFile=OutFile, $
                     XRange=XRange,     YRange=YRange

      ; NH3 
      OutFile = OutDir + 'biomass_200110/' + Extract_Filename( InFile2[Y] )
      Create_Nested, InFile=InFile2[Y], OutFile=OutFile, $
                     XRange=XRange,     YRange=YRange

      ; BCPO 
      OutFile = OutDir + 'biomass_200110/' + Extract_Filename( InFile3[Y] )
      Create_Nested, InFile=InFile3[Y], OutFile=OutFile, $
                     XRange=XRange,     YRange=YRange

      ; OCPO
      OutFile = OutDir + 'biomass_200110/' + Extract_Filename( InFile4[Y] )
      Create_Nested, InFile=InFile4[Y], OutFile=OutFile, $
                     XRange=XRange,     YRange=YRange
   endfor

   ; SO2 seasonal
   InFile  = InDir  + 'SO2.bioburn.seasonal.geos.1x1'
   OutFile = OutDir + 'biomass_200110/SO2.bioburn.seasonal.geos.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; NH3 seasonal
   InFile  = InDir  + 'NH3.bioburn.seasonal.geos.1x1'
   OutFile = OutDir + 'biomass_200110/NH3.bioburn.seasonal.geos.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; BCPO seasonal
   InFile  = InDir  + 'BCPO.bioburn.seasonal.geos.1x1'
   OutFile = OutDir + 'biomass_200110/BCPO.bioburn.seasonal.geos.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ; OCPO seasonal
   InFile  = InDir  + 'OCPO.bioburn.seasonal.geos.1x1'
   OutFile = OutDir + 'biomass_200110/OCPO.bioburn.seasonal.geos.1x1'
   Create_Nested, InFile=InFile, OutFile=OutFile, XRange=XRange, YRange=YRange

   ;====================================================================
   ; Return
   ;====================================================================
Quit:
   return
end
