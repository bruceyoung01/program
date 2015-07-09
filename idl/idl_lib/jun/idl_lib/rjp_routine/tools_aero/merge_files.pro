Pro merge_files, files, outfile=outfile

 For N = 0, N_elements(Files)-1 do begin
   file = Files[N]
   Ctm_get_Data, Datainfo, Category, Filename=file, tracer=Tracer

   If N eq 0 then Thisdatainfo = Datainfo else $
    Thisdatainfo = [Thisdatainfo, Datainfo]

   Undefine, Datainfo
 Endfor

 CTM_WRITEBPCH, Thisdatainfo, ThisFileinfo, filename=outfile

End
