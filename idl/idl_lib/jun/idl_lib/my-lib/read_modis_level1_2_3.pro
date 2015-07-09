pro modis_atmos
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;    PRO MODIS_ATMOS
;
; This Program is designed for MODIS Level-2 & 3 Atmospheric products. However,
; it can also read other HDF files such as Level 1B radiance & subsets,
;  ocean and land products. This is an IDL based program. It reads an HDF-EOS
; data file, creates binary and ascii files for the specific parameter
; requested by the user.
; Some times user may not have x-window capability or user may not be interested
; in displaying image. The parameters are displayed only (for quick-looks)
; if the user selects the display option. Also entering of the input file name
; has option of either use dialogue box or enter it by typing the file-name
; from the keyboard.
;
;
; The objective of developing this program has been to give a very simple code
; (consisting of few basic HDF commands) to the user. This will not only serve
; the purpose of extracting the specific parameter but also if user needs they
; can use this code to insert in their algorithms
;
; To run this program, simply go in IDL session and then type:
;
;  IDL>   .run modis_atmos.pro
;  IDL>    modis_atmos
;
; ;;;;;;;;;;;;;;;;;;;;;;
;
; ATMOSPHERIC DATA format
;
;;;;;;;;;;;;;;;;;;;;;;;;
;
; The atmospheric products are stored in EOS-HDf file format. Within the HDF
; file, in general all parameters are stored as Scientific Data Sets (SDS's).
; However cloud product(MOD06_L2) contains two parameters 'Band_Number' and
;'Statistics_1km'and Atmospheric Profiles product (MOD07_L2) contain two
; paramteres ('Band_Number' and 'Pressure_Level')which  are stored in HDF files
; as VData (table arrays). Since only two type of HDF objects are on
; atmospheric HDf files, this program is set to read only SDS and Vdata.
;
; In each level-2 product, Quality assurance and cloud mask/flag informations are
; provided by assigning number of bytes to each pixel. Individual bits or group
; of bits are set to denote various cloud conditions or quality flags which are
; a;;licable for that pixel. An example of unpacking is given for one conditions
; 'land/water mask' which consists of last two bits of first byte of Cloud Mask
; parameter.
;
; Quality Assurance parameters in all atmospheric level-2 products and
; parameters 'Cloud_Mask_1km' and 'Effective_Radius_difference' in cloud product
; (MOD06_L2) are saved in reverse order, i.e. array have dimensions(Z-size,xsize,ysize)
; compared to other three dimensional parameters which are saved as
;(x-size,y-size,Z-size). This program contains code which saves it in reverse
; format (not activated) user can implement it.
;
;
; For suggestions or comments please contact
;
; Dr. Suraiya Ahmad
; MODIS Data Support Team (MDST)
; Goddard DAAC, NASA/GSFC
; 301-614-5284
; email:ahmad@daac.gsfc.nasa.gov
;
; Latest Version:
; Feb 06, 2002 (assigned new min value for color scale)
; Nov 13 , 2001 (added option of reading Land Products)
; Oct 22, 2001 (changed of color scale for the quick looks)
; Aug 13, 2001 (added option to read Level 1B radiance & subsets)
; May 3, 2001 (added option of ascii file '__.asc' for data output,
;             and a text file 'log.txt' for saving processing info)
;Feb 22, 2001 (added an option for Data conversion to Physical Units)
;Old  Version: Oct 19, 2000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   close,20
   openw,20,'log.txt'
  nf=0
  product='atmos'
;  print,'Program is set to read Atmospheric Products'
  print,' Please Type 1  For reading Level 1B Radiance Product'
  print,'             2  For Atmospheric Product,'
  print,'             3  For Ocean Product'
  print,'             4  For Land Product'
  print,'             0   For any other Product'
 read,nf
 if(nf eq 1)then product='L1B'
if(nf eq 2)then product='atmos'
if(nf eq 3)then product='ocean'
if(nf eq 4)then product='land'
if(nf eq 0)then product='other'

; Read 'file name'
  input_file=" "

  nx=0
  print,'If you have x-window and want to use dialogue box for entering file name'
  print,' please Type 1 (else type 0 )'
  read,nx

; Use a filename dialogue box
  if (nx eq 1) then input_file = dialog_pickfile()

  if(nx gt 0)then goto, next
  print," "
  print, "Please Enter Input File Name"
  print," "
  print, "If file is not in this directory, please use full directory path"
  print," "
  read,input_file
;
;===========
next:
  fill_value=-666
  vrange=intarr(2)
  vrange(0)=-9999
  vrange(1)=9999
  parm_units='none'
  offset=fltarr(36)
  sfactor=fltarr(36)
  offset(0)=0.0
  sfactor(0)=1.0
  parmindx=0
  nbands=1
  print,' '
  printf,20,'==========================='
  print,'your input file is:   ',input_file
  printf,20,'your input file is:   ',input_file

;Open an HDF file for READ(first get file ID, and  SD interface ID)
  file_id=HDF_OPEN(input_file,/READ)
  sd_interface_id=HDF_SD_START(input_file,/READ)


  print," "
  print,"Processing HDF File :  ",input_file
  print," "

; list all sds datasets
PRINT_SDS_INFO, sd_interface_id,datasets
if (datasets eq 0) then begin
print,'There is no SDS in the file'
 goto,done0
endif

print,' '
;==========================================================
; Retrieve User Requested SDS Data
; USE  Short Name or Index for RETRIEVING DATA from an SDS
;============================================================
;
;Option of using 'given' SDS name
   s1_name=" "
;  print, "Enter  Short Name for the SDS Data to be Retrieved:"
;  read, s1_name
;  s1_sds_indx = HDF_SD_NAMETOINDEX(sd_interface_id, s1_name)

;Option of using 'given' SDS Index
   s1_sds_indx=0
   print, "Enter the SDX Index  Number for the SDS Data to be Retrieved:"
   read, s1_sds_indx
   s1_sds_id = HDF_SD_SELECT(sd_interface_id, s1_sds_indx)

print,"====================================="
print," "

; get SDS info
;
   HDF_SD_GETINFO, s1_sds_id, HDF_TYPE=s1_hdf_type, $
   DIMS=s1_dims, NDIMS=s1_ndim, NAME=s1_name, NATTS=s1_natts
;  print,"SDS Index for SDS parameter  ",s1_name, " = ", s1_sds_indx

;==========================================
;start loop over Attributes for the given SDS
;===========================================

  print,"Parameter Short Name=     ", s1_name
  printf,20,"Parameter Short Name=     ", s1_name

    FOR mm=0,s1_natts-1 DO BEGIN

       HDF_SD_ATTRINFO, s1_sds_id, mm, NAME=ss_name, DATA=ss_attr_dat, $
       COUNT=ss_count, HDF_TYPE=ss_hdftype, TYPE=ss_type
       if(ss_name eq '_FillValue') then fill_value= ss_attr_dat(0)
       if(ss_name eq 'valid_range') then vrange= ss_attr_dat
       if(ss_name eq 'units') then parm_units= ss_attr_dat(0)

;=================
;      Default:

         if(ss_name eq 'scale_factor')then sfactor(0)= ss_attr_dat(0)
         if(ss_name eq 'add_offset')then offset(0)= ss_attr_dat(0)

;======================
;      True for Level 1B Radiance & Reflectance Parameters


     if(product eq 'L1B')then begin

      CASE ss_name OF
            'radiance_scales': rdfactor= ss_attr_dat
            'radiance_offsets': rdoffset= ss_attr_dat
            'reflectance_scales': rffactor= ss_attr_dat
            'reflectance_offsets': rfoffset= ss_attr_dat
            'corrected_counts_scales': ccfactor= ss_attr_dat
            'corrected_counts_offsets': ccoffset= ss_attr_dat
            'scaling_factor': spfactor= ss_attr_dat
            'specified_uncertainty': spoffset= ss_attr_dat
            ELSE:
      ENDCASE

     endif

;      True for ocean products

          if( product eq 'ocean')then begin
          if(ss_name eq 'Slope')then sfactor(0)= ss_attr_dat
          if(ss_name eq 'Intercept')then offset(0)= ss_attr_dat
          endif
       print,format='(a,":",t30,5(a))',ss_name,ss_attr_dat
            printf,20,format='(a,":",t30,5(a))',ss_name,ss_attr_dat
       ENDFOR



print," "
  print,"=============================== "
;=====================================================
; Now Time to Get Data (will be stored in array OUT_BUFF0)
;====================================================
;
   HDF_SD_GETDATA, s1_sds_id, out_buff0
  print,s1_name,'  Minimum=',Min(out_buff0),'  Maximum=',max(out_buff0)


;=====================================
; Done with SDS, close the interface
;=====================================
     HDF_SD_ENDACCESS,s1_sds_id
     HDF_SD_END,sd_interface_id
     HDF_CLOSE,file_id

;=================================================
;    End of Data Retrieval,   Now You can use it
;=================================================
;
print,"======================= "
print,"REMEMBER!! "
print,' Requested parameter(original numbers) is Stored in Array OUT_BUFF0'
print,' '
print," The output file will be created, however at the end of program you can print the values"
print,' '
help,out_buff0
print,' '
  if(fill_value ne -666)then begin
  printf,20,'Before converting the numbers to physical quantity: fill_value,min and max = ',$
   fill_value,min(out_buff0),max(out_buff0)
   print,'Before converting the numbers to physical quantity: fill_value, min and max = ',$
   fill_value,min(out_buff0),max(out_buff0)
   endif
   if(fill_value eq -666)then begin
   printf,20,'There is no fill-value'
  printf,20,'Before converting the numbers to physical quantity: min and max = ',$
   min(out_buff0),max(out_buff0)
   print,'Before converting the numbers to physical quantity: min and max = ',$
   min(out_buff0),max(out_buff0)
   endif


print,"======================= "

;   define data type and  working array out_buff

     ndim=size(out_buff0,/n_dimensions)
     dims=size(out_buff0,/dimensions)
     datatype=size(out_buff0,/type)


; Check if data is UINT8 or INT8  array (datatype  eq 1), information may be packed


   if(datatype eq 1)then begin
        ns=0
        nscl=0
        nout=1
        nbinary=1
    out_buff=out_buff0
      goto,output
    endif
;==========================

ns=0
;xyz print,' Do you want to Convert the scaled Numbers given to Physical Quantity'
;xyz print,' If YES, then type 1'
;xyz read,ns
ns=1 ;xtemp


;=========================================

w0=where(out_buff0 eq fill_value,count0)
w1=where(out_buff0 ne fill_value,count1)
;w2=where(out_buff0 gt vrange(1),count2)
;w22=where(out_buff0  ge vrange(0) and out_buff0 le vrange(1),count22)

rfill_value=float(fill_value)
out_buff=float(out_buff0)

;========================================

 if(count1 gt 0)then begin

   if(product eq 'atmos' OR product eq 'other')then begin
     out_buff(w1)=sfactor(0) * ( out_buff(w1)-offset(0) )
    endif
;===================
   if(product eq 'ocean')then begin

       out_buff(w1)=sfactor(0) * out_buff(w1)+ offset(0)
        if (s1_name eq  'cocco_conc_detach') then begin
         out_buff(w1)=10.^(sfactor(0)* out_buff(w1)+offset(0))
         endif

   endif
;=======================
if(product eq 'land')then $
       out_buff(w1)=sfactor(0) * out_buff(w1)+ offset(0)

;===================
  if(product eq 'L1B')then begin

     nbands=1
     if(ndim gt 2) then nbands=dims(2)


   parmindx=0
   print,'enter a processing index for the parameter of interest:'
   print,' 1 for Radiance
   print,' 2 for Reflectances (Not applicable for Emissive Bands)'
   print,' 3 for Corrected Counts'
   print,' 0 for Parameters Other than Above'
print , ' '

   read,parmindx

 if(parmindx eq 0)then begin
    out_buff(w1)=sfactor(0) * ( out_buff(w1)-offset(0) )
    goto, next0
    endif



   ; Radiances
    if(parmindx eq 1)then begin
       for nb=0,nbands-1  do begin
       out_buff(*,*,nb)=rdfactor(nb) * (out_buff(*,*,nb) - rdoffset(nb))
       endfor
     endif

   ; Reflectances
     if(parmindx eq 2)then begin
        for nb=0,nbands-1  do begin
        out_buff(*,*,nb)= rffactor(nb) * (out_buff(*,*,nb) - rfoffset(nb))
        endfor
      endif

 ; Corrected Counts
     if(parmindx eq 3)then begin
      for nb=0,nbands-1  do begin
      out_buff(*,*,nb)=ccfactor(nb) * (out_buff(*,*,nb) - ccoffset(nb))
      endfor
    endif

next0:
    endif
;=========
endif
;==========================================
     if(count0 gt 0)then out_buff(w0)=rfill_value
;     if(count2 gt 0)then out_buff(w2)=rfill_value
;==========================================

;
print,'=============================================='
print,' '
;    print,"REMEMBER!! if there is fill data (may appear here as min) "
     print, "For the data converted to Physical Quantity (floating variable),'
     print,' we made sure that no mathematical operation is applied on fill values,'
     print, 'the fill value is saved as floating-point variable,"
print,"============================================="
print,' '
  if(fill_value ne -666)then begin
  printf,20,'After converting the numbers to physical quantity: fill_value,min and max = ',$
   rfill_value,min(out_buff),max(out_buff)
   print,'After converting the numbers to physical quantity: fill_value, min and max = ',$
   rfill_value,min(out_buff),max(out_buff)
   endif
   if(fill_value eq -666)then begin
   printf,20,'There is no fill-value'
  printf,20,'After converting the numbers to physical quantity: min and max = ',$
   min(out_buff),max(out_buff)
   print,'After converting the numbers to physical quantity: min and max = ',$
   min(out_buff),max(out_buff)
   endif

print," "
     print,' Requested Parameter(scaled values), with no mathematical operation applied, is in Array OUT_BUFF0'
     print,' Requested Data, After Converting to Physical Quantity, is in Array  OUT_BUFF'
     help,OUT_BUFF0,OUT_BUFF


print,"================================================= "
;=================================
;Out put in a file
;==================================
;    nout=0
;     print,'If you want to save this retrieved parameter in a file, type 1 (else type 0):'
;     read,nout
      nout=1

    if (nout eq 1)then begin
       print,' The default is original values'
       print,' scale & offset values are written in file log.txt'
       nscl=0
       print,' '

       print,'If you want to save parameter in the file After converting the numbers to physical quantity , type 1 (else type 0):'
       read,nscl
       print,' '
       nbinary=1

       print,'if you want ascii file (asci file takes more disk space!) please type: 0'

       print,'For binary file, please type 1'
       read,nbinary

;      nscl=1

OUTPUT:

       output_file=" "
       if(nbinary eq 0)then goto, output_asci


       output_file=s1_name+'.bin'
       close,1
       openw,1,output_file
       if(nscl eq 0)then writeu,1,out_buff0
       if(nscl eq 1)then writeu,1,out_buff
       close,1
       print," "

     print,'Your requested data is written in file=   ',output_file
     print,' '
     if(nscl eq 0 )then print,'NOTE: the output file contains Original data from array OUT_BUFF0 (numbers read from file)'
     if(nscl eq 1)then print,'NOTE: the output file contains data from array OUT_BUFF(data after converting into physical quantity)'
     print," "

goto, next2
;
output_asci:
     output_file=s1_name+'.asc'
     openw,1,output_file
     if(nscl eq 0)then printf,1,out_buff0
     if(nscl eq 1)then printf,1,out_buff
     close,1
     print," "
     print,'Your requested data is written in file=   ',output_file
     print,' '

next2:
    if(datatype eq 1)then printf,20,'since Data Type is UINT8 or INT8, there is possibility of more than one info packed, at this time No mathematical operation applied'
   if(datatype eq 1)then print,'since Data Type is UINT8 or INT8, there is possibility of more than one info packed,at this time No mathematical operation applied'

     if(nscl eq 0 )then printf,20,'NOTE: the output file contains Original data from array OUT_BUFF0,  NO mathematical operation applied'
      if(nscl eq 1)then printf,20,'NOTE: the output file contains data from array OUT_BUFF, numbers converted in physical Quantity'
     print," "
     printf,20,'Array Dimensions  ',dims

endif
    print,"=========================================================="
;
     if(ndim lt 3)then test_buff=out_buff

;================================
;

print,' For Quick Look Display, we will use array OUT_BUFF'
print," "

if(ndim gt 2)then begin
nz3=0
nz4=0
print,'For unpacking and Displaying examples, if out_buff is more than 2 dimensions'
print,' then we select one layer or slice from 3rd and 4th dimension of the data'
endif
print,' '
print, "==================="
print, ' '
help,out_buff
;datatype=4 for floating variable,datatype=1 for byte

rdatatype=4

if(ndim eq 3)then begin


 if(dims(0) gt dims(2))then begin
   test_buff=make_array(dims(0),dims(1),type=rdatatype)
    print,'enter a  layer number from third dimension value',dims(2)
    read,nz3
    nz3=nz3-1
   test_buff(*,*)=out_buff(*,*,nz3)
  endif

  if(dims(0) lt dims(2))then begin
    test_buff=make_array(dims(1),dims(2),type=rdatatype)
     print,'enter a  layer number from first dimension value',dims(0)
     read,nz3
     nz3=nz3-1
    test_buff(*,*)=out_buff(nz3,*,*)
  endif

endif

if(ndim eq 4)then begin

  if(dims(0) gt dims(3))then begin
   test_buff=make_array(dims(0),dims(1),type=rdatatype)
     print,'enter a  layer number from third dimension value',dims(2)
      read,nz3
      nz3=nz3-1
     print,'enter a  layer number from fourth dimension value',dims(3)
     read,nz4
     nz4=nz4-1
   test_buff(*,*)=out_buff(*,*,nz3,nz4)
  endif

  if(dims(0) lt dims(3))then begin
   test_buff=make_array(dims(1),dims(2),type=rdatatype)
    print,'enter a  layer number from fourth dimension value',dims(3)
    read,nz3
    nz3=nz3-1
    print,'enter a  layer number from first dimension value',dims(0)
    read,nz4
    nz4=nz4-1
    test_buff(*,*)=out_buff(nz4,*,*,nz3)
   endif

endif


;
print,' '
print,"============================"

 print, 'For quality check: Last three  minima  and top three maxima'
print,' '

printf,20,' '

 printf,20, 'For quality check: Last three  minima and top three maxima'
printf,20,' '
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;stat1,test_buff
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;pro stat1,test_buff
min1=0 & min2=0
dat0=test_buff

min1=min(dat0)
print,'Minimum 1= ',min1
printf,20,'Minimum 1= ',min1
w0=where(dat0 gt min1,count0)

if(count0 gt 0)then begin
min2=min(dat0(w0))
print,'Minimum 2= ',min2
printf,20,'Minimum 2= ',min2
w0=where(dat0 gt min2,count0)
if(count0 gt 0)then begin
min3=min(dat0(w0))
print,'Minimum 3= ',min3
printf,20,'Minimum 3= ',min3
endif
endif
;;;;;;;;;;
max1=max(dat0)
print,'            Maximum 1= ',max1
printf,20,'            Maximum 1= ',max1
w0=where(dat0 lt max1,count0)
if(count0 gt 0)then begin
max2=max(dat0(w0))
print,'            Maximum 2= ',max2
printf,20,'            Maximum 2= ',max2
w0=where(dat0 lt max2,count0)
if(count0 gt 0)then begin
max3=max(dat0(w0))
print,'            Maximum 3= ',max3
printf,20,'            Maximum 3= ',max3
endif
endif

;end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;if(datatype eq 1)then EXTRACT,s1_name,test_buff
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
print,'=================='


display:
nx=0
mmx=600
mmy=500


set_plot,'z'
device,set_resolution=[mmx,mmy]
erase,255
loadct,39
;-------------------
dmin=min(test_buff)
dmax=max(test_buff)
min_all=dmin
max_all=dmax
w22=where(out_buff0  ge vrange(0) and out_buff0 le vrange(1),count22)
if(count22 gt 0) then begin
min_all=min(out_buff(w22))
max_all=max(out_buff(w22))
endif

if(dmin lt min_all)then dmin=min_all
if(dmax gt max_all)then dmax=max_all
print,'please enter minimum for plot'
read,dmin
print,'please enter maximum for plot'
read,dmax
;----------------------
;del=1.0*(max1-min1)/100.0
;dmin=min1+del
;dmax=max1-del
;---------------------
;dmin=min2
;dmin=0
;dmax=max(test_buff)
;--------------------------
;ask user min and max for plotting
;print,min1,min2,min3
;print,max1,max2,max3

dt=test_buff
if(ndim gt 1)then begin

dt=congrid(test_buff,mmx,mmy,/interp)
moddat=bytscl(dt,min=dmin,max=dmax)
gdata=0
print,' if data is global and gridded, please enter 1 (else type 0)'
read,gdata

   if(gdata eq 1)then begin
;if((dims(0) eq 360) and (dims(1) eq 180))then begin
   map_set,0,0,0,/cyl,/grid,/noerase
   warp=map_image(moddat,startx,starty,xsize,ysize,compress=1)
   tv,warp,startx,starty,xsize=xsize,ysize=ysize,order=1
   map_continents,color=255
   map_grid,color=255

   endif else begin
     tv,moddat,order=1
    endelse

    xyouts,.1,.965,/normal, size=1.7,color=210,charthick=2,s1_name

endif

if(ndim eq 1)then begin
 plot,dt, psym=1,xtitle='Data Point', ytitle=s1_name,charsize=1.5,color=210
xyouts,.2,.85,/normal, size=1.5,color=150,charthick=2,s1_name
;xyouts,.14,.20,/normal, size=1.0,color=150,charthick=1.5,'Goddard DAAC MDST'
;xyouts,.17,.16,/normal, size=1.0,color=150,charthick=1.5,'NASA/GSFC'
endif

goto,jp
;==================

gf:
gif_file=s1_name+'.gif'
;wset,1
t=tvrd()
write_gif,gif_file,t
device,/close
print,' '
print, 'GIF file is created :',gif_file
goto,end_imagefile

jp:
jpeg_file=s1_name+'.jpg'
;wset,1
tvlct,red,green,blue,/get
t=tvrd()
s=size(t)
t3=bytarr(3,s(1),s(2))
t3(0,*,*)=red(t)
t3(1,*,*)=green(t)
t3(2,*,*)=blue(t)
write_jpeg,jpeg_file,t3,true=1
device,/close
print,' '
print, 'JPEG file is created :',jpeg_file

end_imagefile:
;======================
print,' '
print,' '
set_plot,'x'
;print,'Display the Data on the Screen:'
print,'If you want to display the image on the screen, Type 1 (else type 0)'
read,nx

 if(nx eq 1)then begin

device,decomposed=0
window,1,xsize=mmx,ysize=mmy,retain=2
loadct,39
erase,255
tv,t
endif
;=======================

;nc=0
print,' if you want to continue for another parameter, type 1 (else type 0)'
read,nc
if (nc eq 1)then goto, next
;;;;;;;;;;;;;;;;;;;;;;;
;goto, done
;;;;;;;;;;;;;;;;;;
done0:
print,' '
nv=0
 print,' If you want to read Vdata Please type 1 (else type 0)'
 read,nv
if (nv ne 1)then goto,done
;
print,'============================="
print,' '
print, 'HDF-VDATA is getting processed'
print,' '
print,'============================="
print,' '
print,' '
print, 'List of HDF V-DATA (table) Follows:'
GET_VDATA, input_file,nfields
if (nfields eq 0) then print,'no VData'
;
;==================================
;
done:
;
close,20
;
print,' '
print,' '
print,'Program ended Successfully'
print,' '
print,' '
print,'================================================================'
print,' '
print,'you may continue the session with your interactive IDL commands'
print,' IDL command HELP will tell you what you have in memory,  Type: help '
print,' '
print,' '
print,'================================================================'
print,' '
print, z

end






PRO PRINT_SDS_INFO, sd_interface_id,datasets

; list all SDS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Retrieve Info about the File
; number of SDS  returned in user variable 'datasets', and
; Global Attributes returned in user variable 'attributes'

HDF_SD_FILEINFO, sd_interface_id, datasets, attributes

print, " Total Number of SDS Datasets:",datasets
print," "

print," Short-Name and and Dimensions of SDS's  are given below:"
print," "
;
;*************************
;
FOR k=0,datasets-1 DO begin     ;start loop over SDS's


; Get an SDS ID given the interface ID

 sk_sds_id=HDF_SD_SELECT(sd_interface_id,k)

;Retrieve information about the kth SD dataset with known sds id

 HDF_SD_GETINFO, sk_sds_id, HDF_TYPE=sk_hdf_type, $
  DIMS=sk_dims, NDIMS=sk_ndims, NAME=sk_name, NATTS=sk_natts

;print,k, sk_name, sk_dims, format='(i0,". ", a,t65," size: ",5(i0,:,"x"))'
print,k, sk_name, sk_hdf_type,sk_dims, format='(i0,". ",a,t53,a,t65," size: ",5(i0,:,"x"))'

ENDFOR

return
end




PRO GET_VDATA,input_file,nfields

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Open the file for read and initialize the Vdata interface
;

input_file=strtrim(input_file,2)
;print,input_file

file_id = hdf_open(input_file,/read)
n_vs= HDF_NUMBER(file_id, TAG= 1963)

IF(n_vs GT 0) Then BEGIN
nvdat=1

; Get the ID of the first Vdata in the file

vdata_id= HDF_VD_GETID(file_id,-1)

while (nvdat lt 3) do begin
;while (vdata_id NE -1) do begin

;attach the id to vdata
vdat=HDF_VD_ATTACH(file_id,vdata_ID,/READ)

;get vdata name
HDF_VD_GET,vdat,CLASS=class, NAME=name, SIZE=size, $
         COUNT=count,FIELDS=fields,  NFIELDS=nfields
;
For i=0, nfields-1 DO BEGIN

nread=HDF_VD_READ(vdat,data)
tst_dat=data
print," "
print, 'Parameter Name: ', name
print,nread,format='("Number of Records = ",i0)'
print,' Data Follows:"

; print Band_Numbers (vdata)
;
if (nvdat eq 1)then begin

;tmp  (to encounter problem in beta version data prior to day 270, 2000)
;tmp    for i=0,2 do begin
;tmp       num=fix(data(i),0,2)
;tmp        nn=2*i
;tmp        tst_dat(nn)=num(0)
;tmp        tst_dat(nn+1)=num(1)
;tmp     endfor
;tmp   tst_dat(6)=fix(data(3),0,1)

;
if(tst_dat(0) eq 0)then tst_dat=data

endif

print,tst_dat
ENDFOR


HDF_VD_DETACH,vdat

nvdat=nvdat+1
;get id of next Vdata

vdata_id= HDF_VD_GETID(file_id,vdata_id)

endwhile
ENDIF


; Close the hdf file
    hdf_close,file_id

return
end




PRO EXTRACT, s1_name,test_buff

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;====================================
; Extract Cloud Mask Tests for MOD35_L2
;====================================
if (s1_name eq 'Cloud_Mask')then begin
;
print, 'For Cloud_Mask'
print,'We give here an example of how one can unpack the Byte'
print,'We have selected Land/Water Mask'
print, '(i.e bit 7 & 8 of Byte 1)'
;
nbyte=1
nbit1=7
nbit2=8
test_buff=out_buff(*,*,nbyte-1) AND (2^(nbit1-1) + 2^(nbit2-1))
count=0
w1=where((test_buff gt 0),count)
print,min(test_buff),max(test_buff)
if(count NE 0)then test_buff(w1)=3
help,test_buff
endif
;==========================================
; Extracting of Quality Assurance for MOD35_L2
;============================================
;
if (s1_name eq 'Quality_Assurance')then begin
;
print, 'For Parameter Quality_Assurance"
print, 'We give here an example of  how One Can Unpack the Byte'
print,'We will retrieve here  Spatial Variability Test Flag '
print, '(i.e bit 2 of Byte 4)'
;
print,' Quality Assurance buffer is in array out_buff(z-size,x-size,y-size)'
print,'We will move it in the array tr_buff(x-size,y-size,z-size)'
print,'It is not needed, done only for consistency with cloud_mask'
;
help,out_buff
print,'This will take few seconds, wait'
xdim=dims(0) & ydim=dims(1) & nb=dims(2)
t1_buff=bytarr(xdim,ydim)
tr_buff=bytarr(xdim,ydim,nb)
For i=0,nb-1 do begin
t1_buff(*,*)=out_buff(i,*,*)
tr_buff(*,*,i)=t1_buff(*,*)
endfor
help,tr_buff
;=======================
; Extract the test bit value
;=======================
nbyte=4
nbit=2
test_buff=tr_buff(*,*,nbyte-1) AND 2^(nbit-1)
count=0
w1=where((test_buff gt 0),count)
if(count NE 0)then test_buff(w1)=1
help,test_buff
print,max(test_buff)
endif

return
end









