;        fd_fdbyte.pro
;PURPOSE:
;        Convert output from fd4d_fdmovie
;        i.e. lon,lat,2,time  array to byte array for movie making.  
;      
;DATE:
;        22 October 1996  
;USAGE NOTES:
; 
; 
;KEYWORD PARAMETERS 
; dsn:        INPUT:  Input data set. 
; date:      INPUT:  Dates of input observations.
;
;-
function fd_fdbyte,fd,date=date,fd0byte2=fd0byte2,fd1byte2=fd1byte2,$
 facred=facred,amax0=amax0,amin0=amin0  
 
if n_elements(amax0) eq 0 then amax0 = 300.
if n_elements(amin0) eq 0 then amin0 = 75.   

if n_elements(facred) eq 0 then facred = 1 
aa = size(fd) & ilmm = aa(1) & ijmm = aa(2) & nobs = aa(4) 
if n_elements(date) then begin & date = fltarr(nobs) & date(*) = 0. & end 
press = grid(sigma=sigma)

;amax0 = max(fd(*,*,0,*),min=amin0) & amax1 = max(fd(*,*,1,*),min=amin1) 
amax1 = amax0 & amin1 = amin0 
fd = (fd > amin0) < amax0  
fac0 = (amax0-amin0) / 255.  & fac1 = (amax1-amin1) / 255.  

fd0byte = bytarr(ilmm,ijmm,nobs) & fd0byte =  reform((fd(*,*,0,*)-amin0)/fac0) 
fd1byte = bytarr(ilmm,ijmm,nobs) & fd1byte =  reform((fd(*,*,1,*)-amin1)/fac1)

t = bytarr(640,512) 
openr,1,'~allen/movie/background.field'  & readu,1,t & close,1
xin = findgen(640)/640. & yin = findgen(512) / 512. 

for i=0,nobs-1 do begin
   print,0,1,i,nobs-1 
   store = fd0byte(*,*,i) 
   store = [store,store(0,*)]
   image = store  
   map_set,0,0.,/cyl,/cont,title='' 
   newimage = map_image(image,startx,starty,xsize,ysize,/bilin) 
 
   case i of
   0: begin
      xout = findgen(xsize)/xsize & yout = findgen(ysize) / ysize
      zag = interp2d(t,xout,yout,xin,yin,/xwrap)
      aa = where(zag gt 0.,count) 
      fd0byte2 = bytarr(xsize,ysize,nobs) 
      end
   else:
   endcase 

   if (count gt 0) then newimage(aa) = 174 
   fd0byte2(0,0,i) = newimage
endfor

for i=0,nobs-1 do begin
   print,1,1,i,nobs-1
   store = fd1byte(*,*,i) 
   store = [store,store(0,*)]
   image = store  
   map_set,0,0.,/cyl,/cont,title='' 
   newimage = map_image(image,startx,starty,xsize,ysize,/bilin) 
   case i of
   0: begin
      xout = findgen(xsize)/xsize & yout = findgen(ysize) / ysize
      zag = interp2d(t,xout,yout,xin,yin,/xwrap)
      aa = where(zag gt 0.,count2) 
      fd1byte2 = bytarr(xsize,ysize,nobs) 
      end
   else:
   endcase 

   if (count2 gt 0) then newimage(aa) = 174 
   fd1byte2(0,0,i) = newimage
endfor 

sizex = 1 & sizey = 1
nnn = size(fd0byte2) & ill = nnn(1) & ijj = nnn(2)  
fd0byte2= rebin(fd0byte2,ill*sizex,ijj*sizey,nobs)
fd1byte2= rebin(fd1byte2,ill*sizex,ijj*sizey,nobs) 
fdbyte = bytarr(xsize,2*ysize,nobs) 

fdbyte(0,0,0) = fd0byte2 
for i=0,nobs-1 do begin
for ij=0,ysize-1 do begin
   fdbyte(0,ij+ysize,i) = fd1byte2(*,ij,i)
endfor
endfor 


xin = findgen(xsize)/xsize & yin = findgen(2*ysize) / (2*ysize)
xout = findgen(xsize/facred)/(xsize/facred)
yout  = findgen(2*ysize/facred)/(2*ysize/facred) 

aa = size(xout) & xsize = aa(1)
aa = size(yout) & ysize = aa(1) 
fd2 = bytarr(xsize,ysize,nobs)
for i=0,nobs-1 do begin
   print,'Interpolate',i,nobs-1
   fd2(0,0,i) = interp2d(fdbyte(*,*,i),xout,yout,xin,yin,/xwrap)
endfor 
return,fd2   
end 



 
