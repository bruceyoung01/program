;=============================================================================
; Startup file for IDL (bmy, 8/27/01), adapted from mgs
;
; NOTES:
; (1) Since "idl_startup.pro" is a batch file, you can't have compound
;      IF-THEN-ELSE clauses.  Single-statement IF clauses are allowable,
;      so we just have to put in a bunch of those instead (mgs, bmy, 7/24/01)
;=============================================================================

; Path settings: Insert your own directories up front!
; A colon must follow each directory!!!
!PATH = '~rjp/IDL/:'            + $
        '~rjp/IDL/gamap/:'      + $
        '~rjp/IDL/tools/:'      + $
        '~rjp/IDL/tools_umd/:'  + $
        '~rjp/IDL/tools_aero/:' + $
        '~rjp/IDL/tools_io/:'   + $
        '~rjp/IDL/regrid/:'     + $
        '~rjp/Data/IDL/:'       + $
        '~rjp/Data/IOA/:'       + $
        '~rjp/IDL/data/:'       + $
        '~rjp/IDL/tools_R/:'    + $
        '~rjp/IDL/tools_rjp/:' + !PATH

; System variable settings
!P.CHARSIZE  = 1.7
;!P.CHARTHICK = 4
!P.CHARTHICK = 2
!P.THICK     = 1
!EDIT_INPUT  = 40

!X.THICK     =4
!Y.THICK     =4
!P.ticklen   =0.02


; No output of status and warning messages for remote shell operation
if ( !D.NAME eq 'NULL' ) then !QUIET = 1

;==============================================================================
; Color set-up etc.
; (should now take care of b/w terminals properly)
;==============================================================================
Device, Get_Visual_Depth=Depth

if ( N_Elements( Depth ) eq 0 ) then Depth = 0

; skip the rest if b/w terminal
if ( Depth lt 4 ) then RetAll 

;-----------------------------------------------------------------------------
; The following section from a newsgroup post by Liam Gumley, 
; Wed, 13 Aug 1998.  This will set the colors correctly on both
; 8-bit, 24-bit, and TRUE COLOR devices.
;
; use (normally 8) bit colors
if ( !VERSION.OS_FAMILY eq 'unix' ) then Device, Pseudo = Depth

; Tell IDL to do the backing store instead of the window manager
; Also use pseudo colors instead of true color
if ( !D.NAME ne 'NULL' ) then Device, Retain=2, Decomposed=0

; open a pixmap window to get color table and allocate space for all
; available colors but 15, so 15 colors are left for other apps
if ( !D.NAME ne 'NULL' ) then Window, /Free, /Pixmap, Colors=-15
;------------------------------------------------------------------------------

; Manually set the default character size and spacing
; This is necessary for SGI, since the SGI default fonts are huge!
if ( !D.NAME ne 'NULL' ) then Device, Set_Character_Size = [ 6, 9 ]

; Call MYCT_SETCOLOR from the TOOLS library to define the colortable
if ( !D.NAME ne 'NULL' ) then MyCt_SetColor, NColors=238, /Verbose;, /rjp;, /Dial

; delete pixmap window so that plotting will create visible one
if ( !D.NAME ne 'NULL' ) then WDelete


