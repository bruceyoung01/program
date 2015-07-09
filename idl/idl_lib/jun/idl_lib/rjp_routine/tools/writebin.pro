; $Id: writebin.pro,v 1.1.1.1 2003/10/22 18:09:36 bmy Exp $
pro readbin,filename,data,header

    openr,ilun,filename,/get_lun,/f77_unformatted

    tmp = bytarr(40)   ; test file typ eID  (catch error !!)

    readu,ilun,tmp
print,string(tmp)

    ; read size information
    s1 = 0L
    s2 = 0L
    readu,ilun,s1,s2

    ; read variable names
    header = strarr(s1)
    for i=0,s1-1 do begin
       readu,ilun,tmp
       ; convert byte array to string and trim
       tmps = string(tmp)
       header[i] = strtrim(tmps,0)
    endfor

    ; read data array
    data = fltarr(s1,s2)
    readu,ilun,data

    free_lun,ilun

return
end




pro writebin,filename,data,header

    ; write a binary file from a standard data array

    if (n_elements(filename) eq 0 OR n_elements(data) lt 2 $
        OR n_elements(header) lt 1) then begin
help,filename,data,header
       print,'*** WRITEBIN,filename,data,header !! ***'
       return
    endif


    ; check size consistency
    s = size(data)
    if (s[0] ne 2) then return
    if (s[1] ne n_elements(header)) then begin
       print,'*** WRITEBIN: header and data columns must have same size ***'
       return
    endif

    if (s[3] ne 4) then begin
       print,'*** WRITEBIN: Data not float: will convert ... ***'
       tmp = data
       data = float(data)
    endif

    


    openw,ilun,filename,/get_lun,/f77_unformatted

    ; write file type identifier
    fileid = 'binary simple 2d -- VERSION 1.00                     '
    tmpfid = byte(fileid)
    writeu,ilun,tmpfid[0:39]

    ; write size information and header
    writeu,ilun,s[1],s[2] 

    ; header will be fixed format: 40 characters, one entry in each record
    for i=0,s[1]-1 do begin
        tmph = [ byte(header[i]), replicate(32B,40) ]
        writeu,ilun,tmph[0:39]
    endfor

    ; write data
    writeu,ilun,data

    free_lun,ilun

    ; restore original data if it was converted
    if (s[3] ne 4) then data=tmp

return
end



pro speedtest

   ; compare reading time ascii vs binary

   start0 = systime(-1)

   readdata,'~/IDL/chem1d/pemtdc8_hno3.dat',d1,h1, $
         skp1=1,skp2=1,delim=' '

   stop0 = systime(-1)

   readbin,'~/tmp/test.bin',d2,h2

   stop1 = systime(-1)

   print,'ASCII : ',stop0-start0,' secs'
   print,'BIN   : ',stop1-stop0,' secs'
   print
help,h1,h2,d1,d2
   print,h1 
   print,'---'
   print,h2
   print,'---'
   print,where(d1 ne d2)

return
end

