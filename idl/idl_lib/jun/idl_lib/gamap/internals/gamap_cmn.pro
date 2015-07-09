; $Id: gamap_cmn.pro,v 1.1.1.1 2007/07/17 20:41:47 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GAMAP_CMN
;
; PURPOSE:
;        Contains global common block for Global Atmospheric Model 
;        output Analysis Package include file (include with @gamap_cmn)
;
; CATEGORY:
;        GAMAP Internals
;
; CALLING SEQUENCE:
;        @gamap_cmn
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
;        None
;
; REQUIREMENTS:
;        Referenced by gamap_init.pro and gamap.pro
;
; NOTES:
;        None
;
; MODIFICATION HISTORY:
;        mgs, 14 Aug 1998  INITIAL VERSION
;        mgs, 21 Jan 1999: - added postscript variables
;        bmy, 22 Feb 1999: - added options for animation (GIF, MPEG filenames)
;        bmy, 10 Dec 2002: GAMAP VERSION 1.52
;                          - removed DO_MPEG and DEFAULTMPEGFILENAME
;                          - added DO_BMP and DEFAULTBMPFILENAME
;                          - added DO_JPEG and DEFAULTJPEGFILENAME
;                          - added DO_PNG and DEFAULTPNGFILENAME
;                          - added DO_TIFF and DEFAULTTIFFFILENAME 
;        bmy, 13 Nov 2003: GAMAP VERSION 2.01
;                          - re-added DO_MPEG and DEFAULTMPEGFILENAME
;                          - removed CREATEANIMATION, this was only
;                            ever used for XINTERANIMATE (obsolete)
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1998-2007, Martin Schultz,
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine gamap_cmn"
;-----------------------------------------------------------------------


COMMON gamapcom, DefaultModel,        $ ; model name default for select_model
                 DefaultPath,         $ ; default search path for CTM_OPEN_FILE
                 CreatePostscript,    $ ; default flag for PS output 
                 AddTimeStamp,        $ ; default for timestamp on ps plots
                 DefaultPSFilename,   $ ; default filename for postscript
                 CreateBMP,           $ ; default flag for BMP output
                 DefaultBMPFileName,  $ ; default filename for GIF output
                 CreateGIF,           $ ; default flag for GIF output
                 DefaultGIFFileName,  $ ; default filename for GIF output
                 CreateJPEG,          $ ; default flag for JPEG output
                 DefaultJPEGFileName, $ ; default filename for JPEG output
                 CreatePNG,           $ ; default flag for PNG output
                 DefaultPNGFileName,  $ ; default filename for PNG output
                 CreateTIFF,          $ ; default flag for TIFF output
                 DefaultTIFFFileName, $ ; default filename for TIFF output
                 CreateMPEG,          $ ; default flag for MPEG output
                 DefaultMPEGFileName, $ ; default filename for MPEG output
                 ;------------------------------------------------------------
                 ; Prior to 11/13/03:
                 ; This flag was only ever used for XINTERANIMATE
                 ; and now that has been supplanted by MPEG (bmy, 11/13/03)
                 ;CreateAnimation,     $ ; default for XINTERANIMATE flag
                 ;------------------------------------------------------------
                 pGlobalFileInfo,     $ ; pointer to global fileinfo structure
                 pGlobalDataInfo,     $ ; pointer to global datainfo structure
                 Debug                  ; flag debug mode


    ; if not already done, initialize variables in common block
    ; prevent infinite loop if gamap.cmn is included in gamap_init.pro
    if ( StrUpCase( Routine_Name() ) ne 'GAMAP_INIT' ) then gamap_init



