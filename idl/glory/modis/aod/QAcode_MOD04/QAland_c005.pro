;pro qLAND_c005

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Success/Failed pseudo flag and Discrete Color Bar for C005
;
; Purpose:
; Create images of the entire QA_10km Bit Field Flag from a
; 04_L2 HDF file. Data is unmapped. That is,
; one pixel in the image is equivalent to one pixel in the data.
;
; Credits:
; Written by Paul A. Hubanks
;
; Version
; 1.0  (Sept 02 2004)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Specify HDF Filename

numberFiles=1
HDFFileName = STRARR(numberFiles)
HDFFileName(0)="./MOD04_L2.A2001124.1535.hdf"
HDFFileName(0)="./MYD04_L2.A2003120.1935.hdf"

; SDS to read from HDF File
variable="Quality_Assurance_Land"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Number of Flags
flagnum=6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variable name used as image title and filename prefix
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SDS Name to print on Image
title = STRARR(flagnum)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Byte and Bit Position of Flag in BitString SDS Array is 0 indexed
; First Byte is byte 0, bits are numbered 0 to 7
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
QA_Byte = INTARR(flagnum)
QA_Start_Bit = INTARR(flagnum)
QA_Num_Bits = INTARR(flagnum)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Number of QA categories (valid QA flag settings)
;   min QA value assumed = 0
;   max QA value assumed 1 less than number of categories
;   (see hardwire just after NUM loop)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
qanum = INTARR(flagnum)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Labels for color bar
;  or definitions of valid QA flag settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
scalelabel = strarr(flagnum,16)




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Specify All Flags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

title(0) = "wave0.47_Usefulness_Land_QA"
QA_Byte(0) = 0
QA_Start_Bit(0) = 0
QA_Num_Bits(0) = 1
qanum(0) = 2
scalelabel(0,0) = "Not Useful (0)"
scalelabel(0,1) = "Useful (1)"

title(1) = "wave0.47_Confidence_Land_QA"
QA_Byte(1) = 0
QA_Start_Bit(1) = 1
QA_Num_Bits(1) = 3
qanum(1) = 4
scalelabel(1,0) = "No Confidence or Fill (0)"
scalelabel(1,1) = "Marginal (1)"
scalelabel(1,2) = "Good (2)"
scalelabel(1,3) = "Very Good (3)"

title(2) = "wave0.66_Usefulness_Land_QA"
QA_Byte(2) = 0
QA_Start_Bit(2) = 4
QA_Num_Bits(2) = 1
qanum(2) = 2
scalelabel(2,0) = "Not Useful (0)"
scalelabel(2,1) = "Useful (1)"

title(3) = "wave0.66_Confidence_Land_QA"
QA_Byte(3) = 0
QA_Start_Bit(3) = 5
QA_Num_Bits(3) = 3
qanum(3) = 4
scalelabel(3,0) = "No Confidence or Fill (0)"
scalelabel(3,1) = "Marginal (1)"
scalelabel(3,2) = "Good (2)"
scalelabel(3,3) = "Very Good (3)"


title(4) = "Inversion_Performed_Land_QA"
QA_Byte(4) = 1
QA_Start_Bit(4) = 0
QA_Num_Bits(4) = 4
qanum(4) = 12
scalelabel(4,0) = "Retrieval performed normally (0)"
scalelabel(4,1) = "Procedure 2 (1)"
scalelabel(4,2) = "Some water pixels in 10x10 box (2)"
scalelabel(4,3) = "Some cirrus possible (3)"
scalelabel(4,4) = "Fitting error > 0.25 (4)"
scalelabel(4,5) = "AOD < 0.0 (5)"
scalelabel(4,6) = "#Pixels between 12 and 20 (6)"
scalelabel(4,7) = "#Pixels between 21 and 30 (7)"
scalelabel(4,8) = "#Pixels between 31 and 50 (8)"
scalelabel(4,9) = "Angstrom out of bounds (9)"
scalelabel(4,10) = "AOD < 0.2 (10)"
scalelabel(4,11) = "Retrieval not performed (11)"

title(5) = "Inversion_Not_Performed_Land_QA"
QA_Byte(5) = 1
QA_Start_Bit(5) = 4
QA_Num_Bits(5) = 4
qanum(5) = 7
scalelabel(5,0) = "Retreival performed normally (0)"
scalelabel(5,1) = "Angles out of bounds (1)"
scalelabel(5,2) = "Apparant Reflectance out of bounds (2)"
scalelabel(5,3) = "# Pixels < 12 (3)"
scalelabel(5,4) = "No PROCEDURE performed (4)"
scalelabel(5,5) = "AOD < -0.100 (5)"
scalelabel(5,6) = "AOD > 5.0 (6)"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set Color Table Assignments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print,' # of colors = ', !D.N_Colors

red=bytarr(256)
grn=bytarr(256)
blu=bytarr(256)



LUTR=BYTARR(256)
LUTG=BYTARR(256)
LUTB=BYTARR(256)

r=bytarr(23)
g=bytarr(23)
b=bytarr(23)


r = [  0,225,139,098,  8,  8,  8,  8,  8,  8,  8,  8,255,222,205,230,230,230,230,255,204,153,102]
g = [  0,225,  8,  8,  8,106,148,172,205,222,213,197,255,238,205,172,139,106, 53,  0,  0,  0,  0]
b = [  0,225,213,213,222,222,238,222,172,139, 90,  8,  0,  8,  8,  8,  8,108,058,  0,  0,  0,  0]



for i=0,21 do begin
red(i*11:i*11+10)=r(i)
grn(i*11:i*11+10)=g(i)
blu(i*11:i*11+10)=b(i)
endfor


red(242:253)=r(22)
grn(242:253)=g(22)
blu(242:253)=b(22)




;assign 254 to white
red(254)=255
grn(254)=255
blu(254)=255


;assign 255 to black
red(255)=000
grn(255)=000
blu(255)=000



;reload modified color table
tvlct,red,grn,blu





FOR k = 0, numberFiles-1 do begin







;;;;;;;;;;;;;;;
; Read L2 Data
;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Read in the 1km Data:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HDFFileID = HDF_SD_START(HDFFileName(k),/READ)

Read_product_sds, L2QA, range, fillvalue, HDFfileID, variable, $
                   fail, /scaleNo, /offsetNo, /validrangeNo, /fillNo

;;Read_product_sds, array, range, fillvalue, HDFfileID, variable, $
;;                   fail

HDF_SD_END, HDFFileID

;help, L2QA







; Determine the size of the SDS array:
dims = size(L2QA,/dimensions)

;;;;;;;;;;;; Regular QA Arrays ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Transpose Regular QA arrays from [band,x,y] to [x,y,band]
; native L2 array dimensions (203,135,#bytes)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

L2QA = TRANSPOSE(L2QA, [1, 2, 0])

; Set array dimensions
xdim = dims(1)
ydim = dims(2)
nbands = dims(0)

;help, L2QA


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


FOR NUM=0,flagnum-1 DO BEGIN


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; QA min and max values
;   Assume min = 0
;   max = 1 less than number of categories
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rmin=0
rmax=qanum(NUM)-1 


variablenew = variable + "  " + title(NUM)





;Create the integer QA Flags output array:

temp = IntArr(xdim,ydim)

;;;;;;; ;Extract the appropriate QA Flag:
; temp[*,*] = ISHFT((L2QA[*,*,QA_Byte(NUM)] AND 192B), -QA_Start_Bit(NUM))

; Grab the byte "QA_Byte" and
;  shift the byte to the right by the start bit value 
;  (this eliminates all less significant bits)

temp[*,*] = ISHFT( L2QA[*,*,QA_Byte(NUM)], -QA_Start_Bit(NUM))

;help, temp

if(QA_Num_Bits(NUM) EQ 1) then mask = 1B
if(QA_Num_Bits(NUM) EQ 2) then mask = 2B + 1B
if(QA_Num_Bits(NUM) EQ 3) then mask = 4B + 2B + 1B
if(QA_Num_Bits(NUM) EQ 4) then mask = 8B + 4B + 2B + 1B
if(QA_Num_Bits(NUM) EQ 5) then mask = 16B + 8B + 4B + 2B + 1B
if(QA_Num_Bits(NUM) EQ 6) then mask = 32B + 16B + 8B + 4B + 2B + 1B
if(QA_Num_Bits(NUM) EQ 7) then mask = 64B + 32B + 16B + 8B + 4B + 2B + 1B
if(QA_Num_Bits(NUM) EQ 8) then mask = 128B + 64B + 32B + 16B + 8B + 4B + 2B + 1B

;help, mask

array = IntArr(xdim,ydim)

array[*,*] = temp AND mask

help, array

print,' min array = ', min(array)
print,' max array = ', max(array)




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;data = array * 1.0  ; ensure it is floating data type
;
;   index = Where(sdsData NE fillValue, ncount)
;
;   IF ncount gt 0 THEN $
;        data[index] = (sdsData[index] - addOffset) * scaleFactor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;Determine the size of the SDS array:
dims = size(array,/dimensions)
xdimgeo = dims(0)
ydimgeo = dims(1)

xg = dims(0) - 1
yg = dims(1) - 1
  

;print, ' min = ', min(array)
;print, ' max = ', max(array)


asize = size(array)

;print,"  "
;print,"  "
;print," ******************** "
;print,"  "










;print,title(NUM)
;help,array

;print,"  "
;print," ******************** "
;print,"  "
;print,"  "

;number of dimensions in array
dim=asize(0)

;size of 1st, 2nd, 3rd, 4th dimension
xdim=asize(1)
ydim=asize(2)
ndim=asize(3)
mdim=asize(4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Begin Building Master Image
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; image = 135 x 203
;   new = 485 x 263

xborder = 350
yborder = 60

new=bytarr(xdim+xborder,ydim+yborder)

;set master image background color to white
new(0:xdim+xborder-1,0:ydim+yborder-1)=254


;;;;;;;;;;;;;;;;;;;;;;;;
; Build a Color Bar
;;;;;;;;;;;;;;;;;;;;;;;;
;print, 'height of image = ',ydim
;print,' height of color bar = ',ydim

; build colorbar (0 to 253 only)
bar=fltarr(40,ydim)
colorbar=bytarr(40,ydim)

icbidx = ydim - 1

; add 0.5 to adjust for truncation (round off)
; this allows the 0 and 253 color bar blocks
; to be the same size (5 pixels in height)
for i=0,icbidx do begin
realval=253.0*(float(i)/float(icbidx))+0.5
bar(0:39,i)=realval
endfor

colorbar=byte(bar)
;print,"barmin = ",min(colorbar),"barmax = ",max(colorbar)
;print,"barbot = ",colorbar(0,0),"bartop = ",colorbar(0,icbidx)



;print, ' dim = ', dim

;;;;;;;;;;;;;;;;;;;;
; Process Image Data
;;;;;;;;;;;;;;;;;;;;


;; if ( dim eq 2 ) then begin

if ( dim eq 2 and rmin ne 1.0 and rmax ne 100.0) then begin

flipped=rotate(array,7)

goto, jump3884

;check for all missing data values (no data)
if (MIN(flipped) eq FillValue and MAX(flipped) eq FillValue) then begin
minvalue = 0.0
maxvalue = 0.0
goto, JUMP1
endif

;compute min and max data values
if (MIN(flipped) eq FillValue) then begin
minvalue = MIN(flipped[WHERE(flipped ne FillValue)])
minvalue = rmin
endif

if (MIN(flipped) ne FillValue) then begin
minvalue = MIN(flipped)
minvalue = rmin
endif

jump3884:

minvalue = rmin
maxvalue = rmax

;print, "datamin = ", minvalue, "datamax = ", maxvalue


;;;;;;;;;;;;;;;;;;;;;;;;;
;;May2003 Scale Fix

;;scale data from 0 to 251
byte_array=bytscl(flipped,min=minvalue,max=maxvalue,top=251) 
;print the scaled byte min and max
;print,"bytemin (0) = ",min(byte_array),"bytemax (251) = ",max(byte_array)

;;scale data from 1 to 252
byte_array=byte_array+1
;print the scaled byte min and max
;print,"bytemin (1) = ",min(byte_array),"bytemax (252) = ",max(byte_array)

;; set data LE minvalue to byte(0)
if (MIN(flipped) le minvalue) then begin
le_array=bytarr(xdim,ydim)
le_array(0:xdim-1,0:ydim-1)=0
byte_array[WHERE(flipped le minvalue)]=le_array[WHERE(flipped le minvalue)]
endif

;; set data GE maxvalue to byte(253)
if (MAX(flipped) ge maxvalue) then begin
ge_array=bytarr(xdim,ydim)
ge_array(0:xdim-1,0:ydim-1)=253
byte_array[WHERE(flipped ge maxvalue)]=ge_array[WHERE(flipped ge maxvalue)]
endif
;;;;;;;;;;;;;;;;;;;;;;;;



JUMP1:

goto, jump4499
;set fillvalue to 255 (black)
if (MIN(flipped) eq FillValue) then begin
;print,'setting fillvalue to 255'
fill_array=bytarr(xdim,ydim)
fill_array(0:xdim-1,0:ydim-1)=255
byte_array[WHERE(flipped eq FillValue)]=fill_array[WHERE(flipped eq FillValue)]
endif


jump4499:














;;;;;;;;;;;;;;;;;;;
; TEXT ANNOTATIONS
;;;;;;;;;;;;;;;;;;;

; display to z buffer
Set_Plot,'Z',/Copy
!p.font=0

;; new=bytarr(xdim+xborder,ydim+yborder)

Device, Set_Colors=256, Set_Resolution=[xdim+xborder,ydim+yborder],set_character_size=[8,9]
Device, set_font='Helvetica',/tt_font

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Set scale size of title and annotations (1.0 is default)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sizenum_title=1.0
sizenum=0.8
sizenum_footer=1.0



fillcolor = 000

;Create Temporary Array for Text


textcolor = 255

base=0
xbase=1440
xbase=xdim+86

barbase=25


;Write Annotations





;; erase XYOUTs window before writing annotation for each image
erase




; sds name
XYOuts,030,base+ydim+40,variablenew,/Device,Color=textcolor,CharSize=sizenum_title

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; compute max qa category looping index
qanum_index=qanum(NUM)-1
; compute scale y-position increment
si=ydim/qanum_index
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; print scale numbers in proper x,y coordinates
for i=0,qanum_index do begin
XYOuts,xbase,barbase+si*i + 5,scalelabel(NUM,i),/Device,Color=textcolor,CharSize=sizenum
endfor

; hdf filename
XYOuts,030,base+8,HDFFilename,/Device,Color=textcolor,CharSize=sizenum_footer




;Read the screen to get text annotation
;print,'read tv screen'
temptext = tvrd(0,0,xdim+xborder,ydim+yborder)
;print,'done reading tv screen!'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Place Text Into Master Image & Write to PNG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mintmp = min(temptext)
maxtmp = max(temptext)
;print, 'min temptext=',mintmp,'max temptext=',maxtmp

; SET BACKGROUND TO WHITE!!!
temptext[where(temptext eq mintmp)]=254
temptext[where(temptext eq maxtmp)]=255




;ADD ANNOTATION
new(0,0)=temptext(0:xdim+xborder-1,0:ydim+yborder-1)

;ADD IMAGE
new(30,30)=byte_array

;ADD COLOR BAR
new(xdim+36,30)=colorbar





;;;;;;;;;;;;;;;;;;
; WRITE PNG IMAGE
;;;;;;;;;;;;;;;;;;
print,'write png' , k

;modisName=strmid(HDFFileName(k), 46, 22)


;image_filename="/Volumes/backup_drive/modis/"+title(NUM)+"_"+modisName+".png"
;image_filename=title(NUM)+"_"+modisName+".png"

image_filename=title(NUM)+".png"
write_image,image_filename,'PNG',new,red,grn,blu


endif




ENDFOR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; END NUM (QA FLAG #) LOOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endfor

end
