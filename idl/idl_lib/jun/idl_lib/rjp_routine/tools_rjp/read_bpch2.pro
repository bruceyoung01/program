Pro read_bpch2, file=file, Diag, time=time, data=data

  if n_elements(Diag) eq 0 then return

  file = file
  tau0 = nymd2tau(time)

  fti       = bytarr(40)
  title     = bytarr(80)
  modelname = bytarr(20) 
  CATEGORY  = bytarr(40)
  Unit      = bytarr(40)
  Reserved  = bytarr(40)

  ntracer   = 1L
  NI        = 1L
  NJ        = 1L
  NL        = 1L
  IFIRST    = 1L
  JFIRST    = 1L
  LFIRST    = 1L
  NSKIP     = 1L
  ZTAU0     = 1d0
  ZTAU1     = 1d0

  openr,il,file,/f77,/get
   readu,il,fti
   print, strtrim(fti,2)

   IF ( strTRIM( FTI, 2 ) ne 'CTM bin 02' ) THEN begin
        PRINT, 'Input file is not in binary file format v. 2.0!'
        PRINT, 'STOP in read_bpch2.pro'
        STOP
   ENDIF

      ; Read top title
      READu,il, TITLE
      print, strtrim(title,2)

      ios = -1L
   while (not eof(il)) do begin

      ios = ios + 1L
      readu, il, MODELNAME, LONRES, LATRES, HALFPOLAR, CENTER180
      print, strtrim(modelname), lonres, latres, halfpolar, center180

      READu, il, $ 
             CATEGORY, NTRACER,  UNIT, ZTAU0,  ZTAU1,  RESERVED, $
             NI,       NJ,       NL,   IFIRST, JFIRST, LFIRST,   $
             NSKIP

            print, strtrim(category,2), ntracer, ztau0, ztau1
            print, NI, NJ, NL, nskip

            array = fltarr(NI,NJ,NL)

      READu, il, array

      If (Diag eq strtrim(category,2) and tau0[0] eq ztau0) then begin
          Data = array
          Goto, Endread
      Endif

   endwhile

Endread: free_lun,il

end
