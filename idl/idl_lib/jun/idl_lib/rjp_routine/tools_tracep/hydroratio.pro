pro readtracep_ep, ethane,  propane

starter = 4
ender = 20
type = 'dc8'
for i=starter,ender do begin
  
   print,  i
   ; read in the measurements
   if i le 9 then begin
      file = '/data/tracep/merge_sept_2001/'+type+$
         '/1min/prelim-mrg60'+strmid(type,0,1)+'0'+$
         string(i, format='(i1)')+'.trp'
   endif else begin
      file = '/data/tracep/merge_sept_2001/'+type+$
         '/1min/prelim-mrg60'+strmid(type,0,1)+$
         string(i, format='(i2)')+'.trp'
   endelse
   
   read_varstr, file, NV, names
   readdata, file,DATA,names_void, delim=',',/autoskip, /noheader, cols=NV, $
      /quiet

   n_ethane = where(names eq 'Ethane')
   n_propane = where(names eq 'Propane')

   if (i eq starter) then begin
      ethane = rotate(data(n_ethane, *), 1)
      propane = rotate(data(n_propane, *), 1)
   endif else begin
      ethane = [ethane, rotate(data(n_ethane, *), 1)]
      propane = [propane, rotate(data(n_propane, *), 1)]
   endelse
   
endfor

end

pro readgeos,  ethane,  propane
   day = 'ts20010318.bpch'
   filename = '/scratch/mje/run_4.16/sense/everything/'+day
   CTM_GET_DATA, DataInfo,file=filename,  tracer=tracer
   k1 = where(datainfo.tracername eq 'C2H6')
   k2 = where(datainfo.tracername eq 'C3H8')
   ethane = *(datainfo(k1).data)
   propane = *(datainfo(k2).data)
   
end
;readtracep_ep, ethane,  propane
;readgeos,  g_ethane,  g_propane
!p.multi = [0, 0, 0, 0, 0]
k = where(ethane ge 0 and propane ge 0)

plot,  ethane(k),  propane(k),  psym=1,  /xlog,  /ylog,  symsize=0.3, $
   xrange=[100, 10000]

oplot,  g_ethane(0:20, 0:15, 0:10)*1e3/2.,  g_propane(0:20, 0:15, 0:10)*1e3/3.,  psym=1,  color=50,  symsize=0.3
end
