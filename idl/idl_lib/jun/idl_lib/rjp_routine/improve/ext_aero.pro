   Spawn, 'ls ctm.bpch_2001??', files

   Outfile = 'IJ-AVG_2001_01-12.bpch'

   Tracers = [7, 8, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, $
              42, 43, 44, 45, 46, 47, 48, 49, 50]

   append = 0
   
   For D = 0, N_elements(Tracers)-1 do begin
     if D eq 0 then append=0 else append=1
     extract, files=files, Category='IJ-AVG-$', Tracer=Tracers[D], $
     outfile=Outfile, append=append
   Endfor


   extract, files=files, Category='BXHGHT-$', $
   outfile=Outfile, /append

   extract, files=files, Category='PS-PTOP', $
   outfile=Outfile, /append

;  Category = ['DMS-BIOG','SO2-AC-$','SO2-AN-$','SO2-BIOF', $
;              'SO2-BIOB','SO2-EV-$','SO2-NV-$','SO4-AN-$'  ]

;  For D = 0, N_elements(Category)-1 do begin
;    if D eq 0 then append = 0 else append = 1
;    extract, files=files, category=category[D], $
;    outfile='SOURCES_2001.4x5.bpch', append=append
;  End
 
 end
