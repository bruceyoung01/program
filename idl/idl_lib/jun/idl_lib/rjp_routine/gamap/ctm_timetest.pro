; $Id: ctm_timetest.pro,v 1.1.1.1 2003/10/22 18:06:04 bmy Exp $


pro ctm_timetest


   stop,'Compile ctm_read3dp_header ctm_read3db_header ctm_read_data'+$
        ' before continuing !'


   ; open ASCII file and read header
   open_file,'~mgs/terra/CTM4/runsep_std/ctm.pch',lun1
   fileinfo1 = create3dfstru()
 
   t0=systime(1) 
   res=ctm_read3dp_header(lun1,fileinfo1,d1,/auto) 
   t1 = systime(1)
   nd = n_elements(d1)
   for i=0,nd-1 do begin
       ctm_read_data,lun1,d1[i].filepos,data, $
             (d1[i].dim[0] > 1),  $
             (d1[i].dim[1] > 1),  $
             (d1[i].dim[2] > 1),  $
             scale=d1[i].scale,format=d1[i].format
   endfor
   t2 = systime(1)

   free_lun,lun1

   print,'ASCII : ',nd,' entries'
   print,'   time for   HEADER   DATA   HEADER/ENTRY   DATA/ENTRY'
   print,'ASCII : ',t1-t0,t2-t1,(t1-t0)/nd,(t2-t1)/nd

   ; open binary file
   open_file,'~bmy/terra/CTM4/run_xfiles/ctm.bpch',lun1,/f77_un
   fileinfo1 = create3dfstru()
 
   t0=systime(1) 
   res=ctm_read3db_header(lun1,fileinfo1,d1) 
   t1 = systime(1)
   nd = n_elements(d1)
   for i=0,nd-1 do begin
       ctm_read_data,lun1,d1[i].filepos,data, $
             (d1[i].dim[0] > 1),  $
             (d1[i].dim[1] > 1),  $
             (d1[i].dim[2] > 1),  $
             scale=d1[i].scale,format=d1[i].format
   endfor
   t2 = systime(1)

   free_lun,lun1

   print,'BINARY: ',nd,' entries'
   print,'   time for   HEADER   DATA   HEADER/ENTRY   DATA/ENTRY'
   print,'BINARY: ',t1-t0,t2-t1,(t1-t0)/nd,(t2-t1)/nd

   return
end
