; $Id: create_usa_mask.pro,v 1.1.1.1 2007/07/17 20:41:35 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CREATE_USA_MASK
;
; PURPOSE:
;        This program defines a mask over the USA.  All grid boxes
;        that are totally contained w/ in the continental US are
;        set equal to 1, with zeroes everywhere else.  Boxes that
;        the USA shares w/ another country are set to zero.
;         
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        CREATE_USA_MASK [, Keywords ]
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;        OUTMODELNAME -> Name of the CTM model grid on which the
;             mask is to be created.  Default is "GEOS_4".  NOTE:
;             since the mask is only a 2-D quantity, all vertical
;             layer information will be ignored.
;
;        OUTRESOLUTION -> Resolution of the CTM model grid on 
;             which the mask is to be created.  Default is 2.
;
;        OUTFILENAME -> Name of the output file (BPCH format) which
;             will contain the USA mask data.  Default is 
;             "usa_mask.geos.{RESOLUTION}"
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;       External Subroutines Required:
;       =====================================================
;       CTM_TYPE          (function)   CTM_GRID   (function)
;       CTM_MAKE_DATAINFO (function)   CTM_RESEXT (function)
;       CTM_WRITEBPCH
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        May not yet work for 4x5.
;
; EXAMPLE:
;        CREATE_USA_MASK, OUTMODELNAME="GEOS4",           $
;                       OUTRESOLUTION=4,                $
;                       OUTFILENAME='usa_mask.geos.4x5'
;
;             ; Creates a USA mask for the GEOS-4 4x5 grid and
;             ; saves it to a bpch file named "us_mask.geos.4x5"
;
; MODIFICATION HISTORY:
;  rch & bmy, 22 Jun 2004: VERSION 1.00
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2004-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine create_usa_mask"
;-----------------------------------------------------------------------


pro Create_Usa_Mask, OutModelName=OutModelName,   $
                     OutResolution=OutResolution, $
                     OutFileName=OutFileName
 
   ;====================================================================
   ; Initialization
   ;====================================================================
   
   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, CTM_Make_DataInfo, CTM_ResExt

   ; Keywords
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName = 'GEOS4'
   if ( N_Elements( OutResolution ) eq 0 ) then Resolution   = 2
 
   ; Structures for the grid
   ModelInfo = CTM_Type( OutModelName, Res=OutResolution )
   GridInfo  = CTM_Grid( ModelInfo )
 
   ; Input data array
   InUS = intarr(GridInfo.IMX, GridInfo.JMX)
 
   ;====================================================================
   ; Start creating the USA mask
   ;====================================================================
   lon1 = where( GridInfo.XMid ge -125 and  GridInfo.XMid le -92.5)
   lat1 = where( GridInfo.YMid ge 34 and  GridInfo.YMid le 48)
 
   for i= 0,  n_elements(lon1)-1 do begin
      for j=0,  n_elements(lat1)-1 do begin
         InUS(lon1(i), lat1(j)) = 1
      endfor
   endfor
   
   lon2 = where( GridInfo.XMid gt -92.5 and  GridInfo.XMid le -85)
   lat2 = where( GridInfo.YMid ge 28 and  GridInfo.YMid le 46)
 
   for i= 0,  n_elements(lon2)-1 do begin
      for j=0,  n_elements(lat2)-1 do begin
         InUS(lon2(i), lat2(j)) = 1
      endfor
   endfor
 
   lon3 = where( GridInfo.XMid gt -85 and  GridInfo.XMid le -80)
   lat3 = where( GridInfo.YMid ge 28 and  GridInfo.YMid le 40)
 
   for i= 0,  n_elements(lon3)-1 do begin
      for j=0,  n_elements(lat3)-1 do begin
         InUS(lon3(i), lat3(j)) = 1
      endfor
   endfor
 
 
   lon4 = where( GridInfo.XMid gt -80 and  GridInfo.XMid le -76)
   lat4 = where( GridInfo.YMid ge 28 and  GridInfo.YMid le 42)
 
   for i= 0,  n_elements(lon4)-1 do begin
      for j=0,  n_elements(lat4)-1 do begin
         InUS(lon4(i), lat4(j)) = 1
      endfor
   endfor
 
   lon5 = where( GridInfo.XMid gt -76 and  GridInfo.XMid le -70)
   lat5 = where( GridInfo.YMid ge 28 and  GridInfo.YMid le 44)
 
   for i= 0,  n_elements(lon5)-1 do begin
      for j=0,  n_elements(lat5)-1 do begin
         InUS(lon5(i), lat5(j)) = 1
      endfor
   endfor
 
   lon6 = where( GridInfo.XMid gt -70 and  GridInfo.XMid le -66)
   lat6 = where( GridInfo.YMid ge 28 and  GridInfo.YMid le 46)
 
   for i= 0,  n_elements(lon6)-1 do begin
      for j=0,  n_elements(lat6)-1 do begin
         InUS(lon6(i), lat6(j)) = 1
      endfor
   endfor
 
   lon7 = where( GridInfo.XMid gt -100 and  GridInfo.XMid le -90)
   lat7 = where( GridInfo.YMid ge 28 and  GridInfo.YMid le 38)
 
   for i= 0,  n_elements(lon7)-1 do begin
      for j=0,  n_elements(lat7)-1 do begin
         InUS(lon7(i), lat7(j)) = 1
      endfor
   endfor
 
   lon8 = where( GridInfo.XMid gt -106 and  GridInfo.XMid le -100)
   lat8 = where( GridInfo.YMid ge 32 and  GridInfo.YMid le 38)
 
   for i= 0,  n_elements(lon8)-1 do begin
      for j=0,  n_elements(lat8)-1 do begin
         InUS(lon8(i), lat8(j)) = 1
      endfor
   endfor
 
   lon9 = where( GridInfo.XMid gt -84 and  GridInfo.XMid le -80)
   lat9 = where( GridInfo.YMid ge 26 and  GridInfo.YMid le 30)
 
   for i= 0,  n_elements(lon9)-1 do begin
      for j=0,  n_elements(lat9)-1 do begin
         InUS(lon9(i), lat9(j)) = 1
      endfor
   endfor
 
 
   lat = where( GridInfo.YMid gt 10 and  GridInfo.YMid lt 75)
   lon = where( GridInfo.Xmid lt -60 and GridInfo.Xmid gt -135)
   
   ;### Debug
   ;Temp = InUS(*, lat)
   ;InUS_plot = Temp(lon, *)
   ;
   ;
   ;TvMap, InUS_plot, GridInfo.Xmid(lon), GridInfo.YMid(lat), $
   ;   /Grid, /Countries, /Coasts, /Sample, /CBar, Div=4, $
   ;   Title='InUS',  /KEEP_ASPECT_RATIO,  maxdata=2
 
   ;====================================================================
   ; Create BPCH file
   ;====================================================================

   ; Make DATAINFO structure 
   Success = CTM_Make_DataInfo( Float( InUS ),              $
                                ThisDataInfo,               $
                                ThisFileInfo,               $
                                ModelInfo=ModelInfo,        $
                                GridInfo=GridInfo,          $
                                DiagN='LANDMAP',            $ 
                                Tracer=2L,                  $
                                Tau0=0D,                    $
                                Tau1=0D,                    $
                                Unit='unitless',            $
                                Dim=[ GridInfo.IMX,         $
                                      GridInfo.JMX, 0, 0 ], $ 
                                First=[ 1L, 1L, 1L ],       $
                                /No_Global )
 
   ; Output file name
   if ( N_Elements( OutFileName ) eq 0 ) $
      then OutFileName = 'usa_mask.geos.' + CTM_ResExt( ModelInfo )

   ; Write bpch file
   CTM_WriteBpch, ThisDataInfo, ThisFileinfo, FileName=OutFileName

end
