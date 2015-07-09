dir = './' 			;directory
file1 = '20070508_count.red'	;These are the files to be read in
file2 = '20070508_count.green'
file3 = '20070508_count.blue'

np = 800	;window size x
nl = 800	;window size y

;create two-dimensional byte arrays 
img1=bytarr(np,nl)
img2=bytarr(np,nl)
img3=bytarr(np,nl)

;open files 1,2,3 and read them into the arrays and close
openr,1,dir+file1
openr,2,dir+file2
openr,3,dir+file3
readu,1,img1
readu,2,img2
readu,3,img3
close,1,2,3

;create 4 windows to display images and save them in tif format
window,1,xsize=np,ysize=nl, retain=2
tvscl,img1
write_tiff, 'img1.tif', tvrd(order=1)

window,2,xsize=np,ysize=nl,  retain=2
tvscl,img2
write_tiff, 'img2.tif', tvrd(order=1)

window,3,xsize=np,ysize=nl,  retain=2
tvscl,img3
;write_tiff, 'img3.tif', tvrd(order=1)

window, 4, xsize=np,ysize=nl 
tv, [[[img1]], [[img2]], [[img3]]], true=3
 ; read current window content
  image = tvrd(true=3, order=1)

 ; write to tiff
  write_tiff,  'color.tif', image, $
    PLANARCONFIG=2


end
