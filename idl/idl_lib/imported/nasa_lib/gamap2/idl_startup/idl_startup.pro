;==============================================================================
; $Id: idl_startup.pro,v 1.9 2008/04/15 18:39:00 bmy Exp $
;
; Startup file for IDL -- customized for GAMAP 2.12 (bmy, phs, 4/15/08)
;
; This file is an batch file (i.e. it is a list of IDL statements as
; you would type them from the IDL> command prompt).  There are no
; "pro" and "end" statements, as there would be with regular IDL
; routines.  Also, compound IF statements are not allowed.
;==============================================================================

;-----------------------------------------------------------------------------
; The !PATH variable contains various system directories in which you would
; like IDL to search for source code routines.  We must insert the gamap2/
; directories up front so that IDL will search here before searching through
; the system directories.
;
; You may also add other directories in which you have IDL source code to
; the !PATH variable.  
;------------------------------------------------------------------------------

; Call the IDL routine PATH_SEP to get the path separator token 
; (i.e. the character that you need to separate directories in !PATH). 
; This token is different depending on which OS you are using.
Sep     = Path_Sep( /Search_Path )

; Add directories to the !PATH variable.  Using IDL's EXPAND_PATH routine
; with the '+' sign will also cause any subdirectories to be added to the
; the !PATH variable.  
;
; The /ALL_DIRS flag will cause all subdirectories to be added to !PATH
; and not just the subdirectories containing *.pro files. 

; %%%%%%%%%% IDL 6.1 and earlier %%%%%%%%%%

; Get the IDL system path and all subdirctories
if ( !VERSION.RELEASE lt 6.2 ) then $
   IdlPath = Expand_Path( '+' + !PATH,  /All_Dirs ) 

; Append your directories into the IDL !PATH variable
if ( !VERSION.RELEASE lt 6.2 ) then $
   !PATH   = Expand_Path( '+~/IDL/gamap2/', /All_Dirs ) + Sep + IdlPath

; %%%%%%%%%% IDL 6.2 and later %%%%%%%%%%

; Use the PREF_SET command to append your directories into the default
; IDL search path.  This approach is necessary if you want to use the 
; IDLDE in IDL 7.0 and later versions. (phs, bmy, 4/15/08)
if ( !VERSION.RELEASE ge 6.2 ) then                             $
   Pref_Set, 'IDL_PATH',                                        $
             Expand_Path( '+~/IDL/gamap2/', /All_Dirs ) + Sep + $
             '<IDL_DEFAULT>', /Commit

;-----------------------------------------------------------------------------
; Various default settings
;-----------------------------------------------------------------------------

; Default character size, character thickness, and line thickness
!P.CHARSIZE  = 1.2
!P.CHARTHICK = 1
!P.THICK     = 1

; Default X and Y margins for the PLOT command
!X.MARGIN    = [10,3]
!Y.MARGIN    = [ 4,2]

; !EDIT_INPUT is the # of lines that you can up-arrow recall,
; but this is only defined in IDL versions prior to 6.2. (bmy, 3/21/06)
if ( !VERSION.RELEASE lt 6.2  ) then !EDIT_INPUT = 40

; Suppress status & warning messages for remote shell operation
if ( !D.NAME eq 'NULL'        ) then !QUIET = 1

;-----------------------------------------------------------------------------
; Default device and color settings
;
; These commands will not be executed you if are running IDL on a NULL device
; (e.g. a terminal such as VT100 that can display text but not graphics). 
;-----------------------------------------------------------------------------

; Get visual color depth 
if ( !D.NAME ne 'NULL'        ) then Device, Get_Visual_Depth=Depth
if ( N_Elements( Depth ) eq 0 ) then Depth = 0
if ( Depth lt 4               ) then RetAll   

;-------
; This section comes from a newsgroup post by Liam Gumley, Wed, 13 Aug 1998.  
; This will set the colors correctly on 8-bit, 24-bit, and TRUE COLOR devices.
;
; Use (normally 8) bit colors
if ( !D.NAME ne 'NULL'  and $
     !VERSION.OS_FAMILY eq 'unix' ) then Device, Pseudo=Depth

; Tell IDL to do the backing store instead of the window manager
; Also use pseudo colors instead of true color
if ( !D.NAME ne 'NULL' ) then Device, Retain=2, Decomposed=0

; Open a pixmap window to get color table and allocate space for all
; available colors but 15, so 15 colors are left for other apps
if ( !D.NAME ne 'NULL' ) then Window, /Free, /Pixmap, Colors=-15
;-------

; Manually set the default character size and spacing
; This is necessary for SGI, since the SGI default fonts are huge!
if ( !D.NAME ne 'NULL' ) then Device, Set_Character_Size=[ 6, 9 ]

; Load the WHITE-GREEN-YELLOW-RED custom colortable with MYCT
if ( !D.NAME ne 'NULL' ) then MyCt, /Verbose, /WhGrYlRd

; Test if !MYCT was created before we reference it below
DefSysV, '!MYCT', Exists=MYCT_Exists

; If we have loaded a MYCT color table, then the default background
; color will be white.  Also set the default foreground color to black.
if ( !D.NAME ne 'NULL' and MYCT_Exists ) then !P.COLOR = !MYCT.BLACK

; Delete pixmap window so that plotting will create visible one
if ( !D.NAME ne 'NULL' ) then WDelete

