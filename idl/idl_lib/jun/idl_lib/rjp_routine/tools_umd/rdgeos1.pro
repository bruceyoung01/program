pro rdgeos1, file, date, ilmm=ilmm, ijmm=ijmm, ikmm=ikmm, D2d=D2d, D3d=D3d

if n_elements(file) eq 0 then begin & print, 'Need input file name' & return & end
if n_elements(date) eq 0 then begin & print, 'Need date for extracting' & return & end
if n_elements(ilmm) eq 0 then ilmm = 144
if n_elements(ijmm) eq 0 then ijmm = 91
if n_elements(ikmm) eq 0 then ikmm = 20

bf = strpos(file,'e0054A')
if bf eq -1 then begin & print, 'file name is not correct' & return & end
bf = bf+8
btime = float(strmid(file,bf,6)) & bf = bf+8
etime = float(strmid(file,bf,6)) & bf = bf+7
tag   = strmid(file,bf,3)

print, btime, etime, tag

if (float(date) gt etime) then begin
 print, 'Date is out of range of time period', date, etime
 return 
end

iskip = date-btime

openr,il,file,/f77,/swap_endian,/get

case tag of

 'dyn' : begin
     hdr = fltarr(3)
     p = fltarr(ilmm,ijmm)
     u = fltarr(ilmm,ijmm,ikmm) & v = u & t = u & q = u
     iskip = fix(iskip*4*5)-1
      print, iskip
     for i = 0 , iskip do begin
       readu,il
     end
       readu,il,hdr,p
       readu,il,hdr,u
       readu,il,hdr,v
       readu,il,hdr,t
       readu,il,hdr,q
      print, hdr
     end

 'cld' : begin

         end

 'kzz' : begin

         end

  else : print, 'stop'

  endcase

return
end
