; BPCH_RENUMBER copies a binary punch file to another punch file,
; but writes the tracer number mod 100L.  

pro Bpch_Renumber, File

   ; Close input & output file if I/O error happens
   On_IoError, Quit
            
   ; External functions
   FORWARD_FUNCTION Str2Byte

   ; Open the file
   Open_File, File, Ilun, /F77, /GET_LUN, SWAP_ENDIAN=little_endian()

   ; Open the file
   Open_File, File+'.new', Ilun_OUT, /F77, /GET_LUN, /Write

   ; Times that index the bpch file
   Tau = [    0D,  744D, 1416D, 2160D, 2880D, 3624D,        $
           4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]

   ; Define some variables
   fti        = bytarr(40)
   toptitle   = bytarr(80)
   modelname  = bytarr(20)
   modelres   = fltarr(2)
   mhalfPolar = -1L
   mcenter180 = -1L
   unit       = bytarr(40)
   reserved   = bytarr(40)
   dim        = lonarr(6)
   skip       = -1L

   ; Place file pointer at top of file and read Ident string
   point_lun, ilun, 0L
   readu, ilun, fti
   writeu, ilun_out, fti

   ;Get the location after FTI
   point_lun, -ilun, newpos
   print, '---------------------------------------------'
   print, 'FTI       : ', string(fti)
   print, 'After FTI : ', newpos
   
   ; read the top title
   readu,ilun,toptitle
   writeu, ilun_Out, toptitle
   print, 'Title:', string(toptitle)

   ; get the file pointer position after toptitle
   point_lun, -ilun, newpos
   print, 'After title : ', newpos

   ; Count of data blocks
   count = 0L

   ; Loop thru file
   while ( not EOF( ilun ) ) do begin 

      category = bytarr(40)
      tracer   = 0L
      tau0     = 0D
      tau1     = 0D
      skip     = 0L

      ; Get file pointer at top of the data block
      point_lun, -ilun, newpos
      print, '-------------------------------------------'
      print, 'Top of data block   : ', NewPos

      ; This line is for the new file format
      readu,ilun,modelname,modelres,mhalfpolar,mcenter180
      readu,ilun,category,tracer,unit,tau0,tau1,reserved,dim,skip

      ; Get file pointer position after reading in the crap above
      point_lun, -ilun, newpos    
      print, 'At location of data : ', newpos

      ; Create data array 
      Data = FltArr( Dim[0], Dim[1], Dim[2] )
      readu, Ilun, Data

      ;-----------------------------------------------------------------
      ;### Change modelname
      ;ModelName = Str2Byte( 'GEOS4_30L', 20 )
      ;ModelName = Str2Byte( 'GEOS3_30L', 20 )
      ;ModelName = Str2Byte( 'GEOS3', 20 )
      ;-----------------------------------------------------------------
      ;### Change category
      Category  = Str2Byte( 'BIOFSRCE', 40 )
      ;----------------------------------------------------------------- 
      ;### Change unit
      ;Unit = Str2Byte( 'v/v', 40 )
      ;----------------------------------------------------------------- 
      ;### Change tracer
      ;Tracer = 1L
      ;if ( Tracer eq 41L  ) then Tracer = 2L
      ;if ( Tracer eq 241L ) then Tracer = 202L
      ;----------------------------------------------------------------- 
      ;### Use TAU's from 1985 (assuming 12 data blocks per file)
      ;Tau0 = Tau[ Count      ]
      ;Tau1 = Tau[ Count + 1L ]
      ;Tau0 = 0d0
      ;Tau1 = 0d0
      ;-----------------------------------------------------------------
      ;### Change TAU
      ;Tau0 = Nymd2Tau( 20040701L )     
      ;Tau1 = Tau0 + 24D
      ;----------------------------------------------------------------- 
      ;### Convert from ppbv to v/v 
      ;if ( Tracer lt 25 ) then begin
      ;   Data = Data * 1e-9
      ;   Unit = Str2Byte( 'v/v', 40 )
      ;endif
      ;-----------------------------------------------------------------       
      ;;### renumber tagged Ox
      ;if ( Tracer eq 2 ) then Tracer = 41L
      ;if ( Tracer eq 64 ) then Tracer = 40L
      ;if ( Tracer eq 65 ) then Tracer = 41L
      ;Tracer = 59L
      ;-----------------------------------------------------------------       
      ;### renumber sulfate tracers
      ;if ( Tracer eq 51 ) then Tracer = 25L
      ;if ( Tracer eq 52 ) then Tracer = 26L
      ;if ( Tracer eq 53 ) then Tracer = 27L
      ;if ( Tracer eq 54 ) then Tracer = 28L
      ;if ( Tracer eq 55 ) then Tracer = 29L
      ;if ( Tracer eq 56 ) then Tracer = 30L
      ;if ( Tracer eq 57 ) then Tracer = 31L
      ;if ( Tracer ge 58 ) then Tracer = Tracer - 4L
      ;-----------------------------------------------------------------       
      ;### Creating 18 tracer offline run from fullchem file
      ;case ( Tracer ) of 
      ;   25: Tracer = 51L
      ;   26: Tracer = 52L
      ;   27: Tracer = 53L
      ;   28: Tracer = 54L
      ;   29: Tracer = 55L
      ;   30: Tracer = 56L
      ;   31: Tracer = 57L
      ;    8: Tracer = 58L
      ;   32: Tracer = 59L
      ;   33: Tracer = 60L
      ;   34: Tracer = 61L
      ;   35: Tracer = 62L
      ;   36: Tracer = 63L
      ;   37: Tracer = 64L
      ;   38: Tracer = 65L
      ;   39: Tracer = 66L
      ;   40: Tracer = 67L
      ;   41: Tracer = 68L
      ;endcase
      ;-----------------------------------------------------------------
      ;### For total biomass burned
      ;if ( Tracer mod 100L eq 33 ) $
      ;   then Unit = Str2Byte( 'molec/cm2', 40 )
      ;-----------------------------------------------------------------
      ;### fix for yxw window runs
      ;Dim[3:5] = [ 97, 37, 1 ]
      ;-----------------------------------------------------------------
      ;### Set a uniform mixing ratio field
      ;Data[*] = 0e0
      ;-----------------------------------------------------------------

      ; don't store high tracer numbers in the punch file
      Tracer = Tracer mod 100L

      ; print modified things
      print, 'Ilun      : ', Ilun
      print, 'ModelName : ', String( ModelName )
      print, 'ModelRes  : ', String( ModelRes  )
      print, 'MHalfPolar: ', MHalfPolar
      print, 'MCenter180: ', MCenter180
      print, 'Category  : ', String( Category )
      print, 'Tracer    : ', Fix( tracer )
      print, 'Unit      : ', String( Unit )
      print, 'Reserved  : ', String( Reserved )
      print, 'TAU0, TAU1: ', Tau0, Tau1
      print, 'Dim       : ', Dim
      print, 'Skip      : ', Skip

      ; This line is for the new file format
      WriteU,ilun_OUT,modelname,modelres,mhalfpolar,mcenter180
      WriteU,ilun_OUT,category,tracer,unit,tau0,tau1,reserved,dim,skip
      WriteU,Ilun_OUT,data

      ;pause

      ; Increment count of data blocks
      count = count + 1L

      ; Undefine data array for safety's sake
      UnDefine, Data
    endwhile
 
Quit:

    On_IoError, Null

    ; Close input file
    Close,    Ilun
    Free_lun, Ilun

    ; Close output file
    Close,    Ilun_OUT
    Free_LUN, Ilun_OUT
end
 
 
 
