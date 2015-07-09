; $Id: gif2ps.pro,v 1.1.1.1 2007/07/17 20:41:35 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GIF2PS
;
; PURPOSE:
;        Translates GIF images to PostScript format.
;
; CATEGORY:
;        Graphics
;
; CALLING SEQUENCE:
;        GIF2PS [, FILENAME [, Keywords ] ]
;
; INPUTS:
;        FILENAME (optional) -> Name of the input GIF file.  
;             If FILENAME is omitted then GIF2PS will prompt
;             the user to supply a file name via a dialog box.
;             FILENAME may contain wild card characters.
;
; KEYWORD PARAMETERS:
;        OUTFILENAME -> Name of the output PostScript file.
;             Default is "idl.ps".
;
;        /FLIP_BW -> Set this keyword to turn black pixels into
;             white pixels and vice-versa.  This is useful for
;             creating PostScript files of GIF images that have a 
;             dark background color. 
;
;        XOFFSET, YOFFSET (optional) -> Set these keywords to specify
;             the X and Y Margins in inches.  Defaults are 
;             XMARGIN = 0.5 inches and YMARGIN = 0.5 inches.
; 
;        _EXTRA=e -> Picks up extra keywords for OPEN_DEVICE,
;             TVIMAGE, and CLOSE_DEVICE.
;
; OUTPUTS:
;        Sends output to a PostScript file, whose name is given
;        by the OUTFILENAME keyword.
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        EXTRACT_FILEPATH (function)
;        DIALOG_PICKFILE  (function)
;        TVIMAGE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) Image processing options are limited to flipping the
;            black and white pixels.  This should be good enough
;            for most purposes.
;
;        (2) XMARGIN and YMARGIN assume that we are printing out for
;            standard USA 8.5 x 11" page.  Device sizes listed below
;            are also in inches.  
;
; EXAMPLE:
;        (1)
;        GIF2PS, 'my_gif.gif', OUTFILENAME='my_ps.ps'
;
;             ; Translates the image in "my_gif.gif" to 
;             ; the PostScript file "my_ps.ps".
;
;        (2)
;        GIF2PS, 'my_gif.gif', OUTFILENAME='my_ps.ps', /FLIP_BW
;        
;             ; Same as in (1), but also changes all black
;             ; pixels to white and vice-versa.  
;
;        (3)
;        GIF2PS, 'my_gif.gif', OUTFILENAME='my_ps.ps', /FLIP_BW, $
;             XMARGIN=0.5, YMARGIN=0.5
;        
;             ; Same as in (2), but also will "pad" the image with
;             ; 0.5" of white space around each side.
;
; MODIFICATION HISTORY:
;        bmy, 28 Jan 2000: VERSION 1.45
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2000-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine gif2ps"
;-----------------------------------------------------------------------


pro Gif2Ps, FileName, $
            Flip_BW=Flip_BW,   OutFileName=OutFileName, $
            Portrait=Portrait, XMargin=XMargin,         $
            YMargin=YMargin,   _EXTRA=e
 
   ;====================================================================
   ; External functions / Keyword settings
   ;====================================================================
   FORWARD_FUNCTION Extract_FileName, Dialog_PickFile

   if ( N_Elements( OutFileName ) eq 0 ) then OutFileName = 'idl.ps'
   if ( N_Elements( XMargin     ) eq 0 ) then XMargin     = 0.5 
   if ( N_Elements( YMargin     ) eq 0 ) then YMargin     = 0.5 
   
   ; If FILENAME is missing, or contains a wild card character, 
   ; then prompt the user to select a file via a dialog box
   FMask = '*'
   if ( N_Elements( FileName ) eq 0 ) then FileName = FMask

   if ( StrPos( FileName, FMask ) ge 0 ) then begin
      
      ; Extract the file name and path separately
      FName = Extract_FileName( FileName, FilePath=Path )

      ; Call the dialog box
      ThisFileName = Dialog_PickFile( File=FName,                $
                                      Path=Expand_Path( Path ),  $
                                      Filter=Fmask, $
                                      Title='Choose a GIF file' )
   endif else begin
      ThisFileName = FileName
   endelse

   ;====================================================================
   ; Save the current color table in vectors R_SAV, G_SAV, B_SAV
   ;
   ; Read the GIF file into an image -- save the RGB vectors from
   ; its private colortable in the R, G, B vectors
   ;====================================================================
   TVLct, R_Sav, G_Sav, B_Sav, /Get
 
   Read_GIF, ThisFileName, Image, R, G, B, _EXTRA=e
 
   ;====================================================================
   ; If /FLIP_BW is set, then flip black and white pixels
   ;====================================================================
   if ( Keyword_Set( Flip_BW ) ) then begin

      ; BLACK is the minimum value, WHITE is the maximum value
      BLACK = Min( Image, Max=WHITE )
      Ind_B = Where( Image eq BLACK )
      Ind_W = Where( Image eq WHITE )
 
      ; Flip BLACK into WHITE
      if ( Ind_B[0] ge 0 ) then Image[ Ind_B ] = WHITE
 
      ; Flip WHITE into BLACK
      if ( Ind_W[0] ge 0 ) then Image[ Ind_W ] = BLACK
   endif

   ;====================================================================
   ; Set PS device for either PORTRAIT or LANDSCAPE mode
   ;====================================================================
   if ( Keyword_Set( Portrait ) ) then begin 
       
      ; Compute image sizes for USA 8.5" x 11" paper
      XSize = 8.5  - 2.0 * XMargin
      YSize = 11.0 - 2.0 * YMargin

      ; Set the PS device with the given margins for PORTRAIT output
      Set_Plot, 'PS'
      Device,  /Color,      Bits=8,          /Portrait,             $
               /Inches,     XOffset=XOffset, YOffset=YOffset,       $
               XSize=XSize, YSize=YSize,     FileName=OutFileName,  $
               _EXTRA=e

   endif else begin

      ; Compute image sizes for USA 8.5" x 11" paper
      XSize = 11.0 - 2.0 * XMargin
      YSize = 8.5  - 2.0 * YMargin

      ; Set the PS device with the given margins for LANDSCAPE output
      Set_Plot, 'PS' 
      Device,  /Color,      Bits=8,          /LandScape,           $
               /Inches,     XOffset=XMargin, YOffset=11.0-YMargin, $
               XSize=XSize, YSize=YSize,     FileName=OutFileName, $
               _EXTRA=e

   endelse

   ;====================================================================
   ; Load the color table that came with the GIF file.
   ; This ensures that the PS device will use the
   ; same colortable as the original GIF file.
   ;
   ; Call TVIMAGE to TV the image
   ;
   ; Close the PS device
   ;====================================================================
   TVLct, R, G, B
 
   TVImage, Image, /NoErase, _EXTRA=e
 
   Device, /Close

   ;====================================================================
   ; Restore the saved color table and return
   ;====================================================================
   TVLct, R_Sav, G_Sav, B_Sav
 
Quit:
   return
end
