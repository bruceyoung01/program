; $Id: ctm_read_planeflight.pro,v 1.4 2005/03/29 16:42:02 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_READ_PLANEFLIGHT
;
; PURPOSE:
;        Reads GEOS-CHEM plane flight diagnostic (ND40) data.  
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        RESULT = CTM_READ_PLANEFLIGHT( FILENAME )
;
; INPUTS:
;        FILENAME -> Name of the file containing data from the GEOS-CHEM
;             plane following diagnostic ND40.  If FILENAME is omitted,
;             then a dialog box will prompt the user to supply a file name.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        RESULT -> Array of structures containing data from read from
;             the input file.  Each different plane type will have 
;             a structure in RESULT containing the following tags:
; 
;             NPOINTS  : Number of points read from the file 
;             NVARS    : Number of variables read from the file
;             PLATFORM : Name of plane type (e.g. DC8, P3B, FALCON)
;             DATE     : Array w/ YYYYMMDD  at each flight point [GMT date]
;             TIME     : Array w  HHMM      at each flight point [GMT time]
;             LAT      : Array w/ latitude  at each flight point [degrees ]
;             LON      : Array w/ longitude at each flight point [degrees ]   
;             PRESS    : Array w/ pressure  at each flight point [hPa     ]
;             VARNAMES : Array w/ names of each variable 
;             DATA     : Array w/ data for each variable
;
; SUBROUTINES:
;
;        External Subroutines Required:
;        ==========================================
;        OPEN_FILE   STRBREAK (function)  UNDEFINE
;
; REQUIREMENTS:
;        Requires routines from the TOOLS package.
;
; NOTES:
;        We read the data into arrays first, and then save the arrays
;        into an IDL structure.  If you read the data into an array of
;        structures, this executes much more slowly.  Also arrays of
;        structures seem to suck up an inordinate amount of memory.
;
; EXAMPLES:
;        PLANEINFO = CTM_READ_PLANEFLIGHT( 'plane.log.20040601' )
;             ; Reads data from file into the PLANEINFO structure
;
;        DC8 = WHERE( PLANEINFO[*].PLATFORM eq 'DC801' )
;             ; Look for DC8 data
;
;        PRINT, PLANEINFO[DC8].LAT[*]
;        PRINT, PLANEINFO[DC8].LON[*]
;             ; Prints latitudes and longitudes of DC8 to the screen
;
;        IND = WHERE( PLANEINFO[DC8].VARNAMES eq 'TRA_004' )
;        CO  = PLANEINFO[DC8].DATA[ *, IND ]
;             ; Extracts CO (tracer #4 in a GEOS-CHEM fullchem
;             ; simulation) to an array
;
;        IND  = WHERE( PLANEINFO[DC8].VARNAMES eq 'GMAO_UWND' )
;        UWND = PLANEINFO[DC8].DATA[ *, IND ]
;             ; Extracts U-wind information to an array 
;
; MODIFICATION HISTORY:
;        bmy, 23 Mar 2005: GAMAP VERSION 2.03
;
;-
; Copyright (C) 2005, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_read_planeflight"
;-----------------------------------------------------------------------


function CTM_Read_PlaneFlight, FileName

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External function
   FORWARD_FUNCTION StrBreak

   ; Initialize variables
   ARRSIZE  = 1500L
   VARSIZE  = 100L
   Line     = ''
   Header   = ''
   Count    = 0L
   PId      = ''
   PDate    = 0L
   PTime    = 0
   PLat     = 0.0
   PLon     = 0.0
   PPrs     = 0.0

   ; Sort date for each plane type into a template structure
   Template = { PlaneStru,                             $
                NPOINTS  : 0L,                         $
                NVARS    : 0L,                         $  
                PLATFORM : '',                         $
                DATE     : LonArr( ARRSIZE          ), $
                TIME     : IntArr( ARRSIZE          ), $ 
                LAT      : FltArr( ARRSIZE          ), $
                LON      : FltArr( ARRSIZE          ), $ 
                PRESS    : FltArr( ARRSIZE          ), $
                VARNAMES : StrArr( ARRSIZE          ), $
                DATA     : FltArr( ARRSIZE, VARSIZE ) } 

   ;====================================================================
   ; Open file and read header
   ;====================================================================
 
   ; Open file
   Open_File, FileName, Ilun, /Get_LUN
 
   ; Read header line
   ReadF, Ilun, Line
   
   ; Read names from the header file
   Header  = StrBreak( Line, ' ' )
   N_Hdr   = N_Elements( Header )

   ; The first 7 columns are ID/time/position
   N_Data  = N_Hdr - 7L
   DataHdr = Header[7L:N_Hdr-1L]

   ; Define temporary arrays to read in the data
   Type    = StrArr( ARRSIZE         )
   Date    = LonArr( ARRSIZE         )
   Time    = IntArr( ARRSIZE         )
   Lat     = FltArr( ARRSIZE         )
   Lon     = FltArr( ARRSIZE         )
   Press   = FltArr( ARRSIZE         )
   Data    = FltArr( ARRSIZE, N_Data )
   TmpArr  = FltArr( N_Data          )

   ; Format string
   Fmt = '(6x,A5,X,I8.8,X,I4.4,X,F7.2,X,F7.2,X,F7.2,X,' + $
         String( N_Data ) + '(e10.3,x))'

   ;====================================================================
   ; Read data points from file
   ;====================================================================
 
   ; Loop thru file
   while ( not EOF( Ilun ) ) do begin
 
      ; Read one line at a time
      ReadF, Ilun, Line

      ; Parse the line into scalars
      ReadS, Line, PId, PDate, PTime, PLat, PLon, PPrs, TmpArr, Format=Fmt

      ; Save into arrays
      Type [Count  ] = PId
      Date [Count  ] = PDate
      Time [Count  ] = PTime
      Lat  [Count  ] = PLat
      Lon  [Count  ] = PLon
      Press[Count  ] = PPrs
      Data [Count,*] = TmpArr

      ; Increment count
      Count = Count + 1L

   endwhile

   ; Close file
   Close,    Ilun
   Free_LUN, Ilun

   ;====================================================================
   ; Resize arrays and create PLANEINFO array of structures
   ;====================================================================   

   ; Resize arrays
   Type       = Temporary( Type [0L:Count-1L  ] )
   Date       = Temporary( Date [0L:Count-1L  ] )
   Time       = Temporary( Time [0L:Count-1L  ] )
   Lat        = Temporary( Lat  [0L:Count-1L  ] )
   Lon        = Temporary( Lon  [0L:Count-1L  ] )
   Press      = Temporary( Press[0L:Count-1L  ] )
   Data       = Temporary( Data [0L:Count-1L,*] )

   ; Find unique plane types
   Uniq_Types = Type[ Uniq( Type, Sort( Type ) ) ]
   N_Types    = N_Elements( Uniq_Types )

   ; Create PLANEINFO array of structures
   PlaneInfo  = Replicate( Template, N_Types )

   ; Loop over all unique plane types
   for P = 0L, N_Types-1L do begin
      
      ; Find data belonging to each plane type
      Ind = Where( Type eq Uniq_Types[P], Count )

      ; Save into PLANEINFO structure
      PlaneInfo[P].NPOINTS      = Count
      PlaneInfo[P].NVARS        = N_Data
      PlaneInfo[P].PLATFORM     = Uniq_Types[P]
      PlaneInfo[P].VARNAMES     = DataHdr

      ; Save 1-D arrays into PLANEINFO
      for D = 0L, Count-1L do begin
         PlaneInfo[P].DATE[D]   = Date [ Ind[D] ]
         PlaneInfo[P].TIME[D]   = Time [ Ind[D] ]
         PlaneInfo[P].LAT[D]    = Lat  [ Ind[D] ]
         PlaneInfo[P].LON[D]    = Lon  [ Ind[D] ]
         PlaneInfo[P].PRESS[D]  = Press[ Ind[D] ]  
         
         ; Save 2-D data array
         for V = 0L, N_Data-1L do begin
            PlaneInfo[P].DATA[D,V] = Data[ Ind[D], V ]
         endfor
      endfor

      ; Undefine stuff
      UnDefine, Ind
      UnDefine, Count

   endfor

   ; Return to calling program
   return, PlaneInfo
end
