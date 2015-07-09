 pro extract, files=files, Category=Category, Tracer=Tracer, $
     Outfilename=Outfilename, Append=Append

;+
; pro extract, files=files, Category=Category, Tracer=Tracer, $
;     Outfilename=Outfilename
;-

 If N_elements(Files)       eq 0 then return
 If N_elements(Category)    eq 0 then return
; If N_elements(Tracer)      eq 0 then return
 If N_elements(Outfilename) eq 0 then Outfilename = 'Newdata.bpch'

 For N = 0, N_elements(Files)-1 do begin
   file = Files[N]
   Ctm_get_Data, Datainfo, Category, Filename=file, tracer=Tracer

   If N eq 0 then Thisdatainfo = Datainfo else $
    Thisdatainfo = [Thisdatainfo, Datainfo]

   Undefine, Datainfo
 Endfor

  CTM_writebpch, Thisdatainfo, Filename=Outfilename, Append=Append

  Undefine, Thisdatainfo

 Return

 End
