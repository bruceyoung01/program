;pro plot_calipso_l1_case
;
!p.font = 1

@L1_COMMON
path  = '/media/disk/data/calipso/seas_small/2006/CAL_LID_L1-ValStage1-V3-01'
fname = 'CAL_LID_L1-ValStage1-V3-01.2006-10-09T06-35-50ZD.hdf'
read_hdf_l1,path,fname

L1_nbin = 583
CAL_ALT = fltarr(L1_nbin)
for i=0, L1_nbin-1 do begin
  CAL_ALT[i] = altitude_i(i)
endfor

L1_DEP_532       = L1_PER_BKS_532/(L1_TOT_BKS_532 - L1_PER_BKS_532)

CAL_HGT_60       = cal_lid_60(CAL_ALT)
CAL_TAB532_60    = cal_lid_60(L1_TOT_BKS_532)
CAL_TAB1064_60   = cal_lid_60(L1_BKS_1064)
CAL_DEP532_60    = cal_lid_60(L1_DEP_532)
cal_height_60    = CAL_HGT_60
lidar_bs_60      = CAL_TAB532_60
lidar_bs64_60    = CAL_TAB1064_60
lidar_dep_60     = CAL_DEP532_60
n_cal_60         = n_elements(cal_height_60)
FOR i = 0, n_cal_60 -1 DO BEGIN
  lidar_bs_60[n_cal_60 -1 - i,*]        = CAL_TAB532_60[i,*]
  lidar_bs64_60[n_cal_60-1-i,*]         = CAL_TAB1064_60[i,*]
  lidar_dep_60[n_cal_60 -1 - i,*]       = CAL_DEP532_60[i,*]
  cal_height_60[n_cal_60 -1 - i]        = CAL_HGT_60[i]
ENDFOR
i1 = 0000
i2 = N_ELEMENTS(L1_LAT)-1

image_pos = position_get(1,3,0.10,0.10,0.82,0.95,0.,0.0)
cb_pos    = position_get(1,3,0.93,0.10,0.94,0.95,0.,0.03)
image_pos1=image_pos[0,0,*] & cb_pos1=cb_pos[0,0,*]
image_pos2=image_pos[0,1,*] & cb_pos2=cb_pos[0,1,*]
image_pos3=image_pos[0,2,*] & cb_pos3=cb_pos[0,2,*]
n_cal     = N_ELEMENTS(CAL_ALT)
minh      = 0.0
maxh      = 10.0

for i = 0, n_cal_60 - 2 do begin
  if((cal_height_60[i] lt maxh) and (cal_height_60[i+1] ge maxh)) then begin
    cal_ih2 = i
  endif
  if((cal_height_60[i] lt minh) and (cal_height_60[i+1] ge minh)) then begin
    cal_ih1 = i
  endif
endfor

x_title     = ' '
y_title     = 'Height (km)'
image_title = ' '
xtick       = [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' ,' ' ,' ',' ']

WINDOW,/free,xsize=1200,ysize=400,/pixmap
PLOT,FLTARR(1),/nodata, background=!d.n_colors-1 ; clear background

charsize = 2.5
charthick = 5.0
colorscale,r,g,b
case1_lidar_bs    = lidar_bs_60[cal_ih1:cal_ih2,i1:i2]
temp_array        = transpose(case1_lidar_bs)
temp_array        = 10. * alog10(temp_array)
cb_title          = 'TAB 532 (dB)'
max_histo         = 0
min_histo         = -40
image = bytscl(temp_array,min=min_histo,max=max_histo)
colorscale,r,g,b
TVLCT,r,g,b,/get
r0 = r & g0 = g & b0 = b
r[250:255]= r0[249] & g[250:255] = g0[249] & b[250:255] = b0[249]
TVLCT,r,g,b
tvimage, image, position=image_pos1
plot,/nodata, /noerase, FLTARR(1),position=image_pos1,color = 0,$
yrange=[minh,maxh], yticks = 4, yminor = 5, ytitle=y_title, $
xrange=[L1_LAT[i1],L1_LAT[i2]], xticks = 5, xminor = 2, xtitle=x_title, $
xtickname = xtick,xstyle = 1, charsize = charsize,charthick = charthick,$
xthick = 2.0,ythick = 2.0,ystyle = 1
format = '(F6.4)'
COLORBAR, TITLE=cb_title, RANGE=[min_histo,max_histo],  POSITION=cb_pos1, $
          COLOR=0,DIVISIONS=4,/vertical,charsize = charsize,charthick=charthick

case1_lidar_dep    = lidar_dep_60[cal_ih1:cal_ih2,i1:i2]
temp_array         = TRANSPOSE(case1_lidar_dep)
cb_title           = 'Dep 532'
max_histo          = 0.6
min_histo          = 0.
image = bytscl(temp_array,min=min_histo,max=max_histo)
colorscale,r,g,b
tvimage, image, position=image_pos2
plot,/nodata, /noerase, FLTARR(1),position=image_pos2,color = 0,$
yrange=[minh,maxh], yticks = 4, yminor = 5, ytitle=y_title, $
xrange=[L1_LAT[i1],L1_LAT[i2]], xticks = 5, xminor = 2, xtitle=x_title, $
xtickname = xtick,xstyle = 1, charsize = charsize,charthick = charthick,$
xthick = 2.0,ythick = 2.0,ystyle = 1
format = '(F4.2)'
colorscale,r,g,b
TVLCT,r,g,b,/get
r0 = r & g0 = g & b0 = b
r[250:255]= r0[249] & g[250:255] = g0[249] & b[250:255] = b0[249]
TVLCT,r,g,b
COLORBAR, TITLE=cb_title, RANGE=[min_histo,max_histo],FORMAT=format,$
          POSITION=cb_pos2, COLOR=0,DIVISIONS=4,/vertical,charsize = charsize,charthick=charthick

case1_lidar_bs64  = lidar_bs64_60[cal_ih1:cal_ih2,i1:i2]
temp_array        = transpose(case1_lidar_bs64)
temp_array        = 10. * alog10(temp_array)
cb_title          = 'TAB 1064 (dB)'
max_histo         = 0
min_histo         = -40
image = bytscl(temp_array,min=min_histo,max=max_histo)
colorscale,r,g,b
TVLCT,r,g,b,/get
r0 = r & g0 = g & b0 = b
r[250:255]= r0[249] & g[250:255] = g0[249] & b[250:255] = b0[249]
TVLCT,r,g,b
tvimage, image, position=image_pos3
plot,/nodata, /noerase, FLTARR(1),position=image_pos3,color = 0,$
yrange=[minh,maxh], yticks = 4, yminor = 5, ytitle=y_title, $
xrange=[L1_LAT[i1],L1_LAT[i2]], xticks = 5, xminor = 2, xtitle=x_title, $
xstyle = 1, charsize = charsize,charthick = charthick,$
xthick = 2.0,ythick = 2.0,ystyle = 1
format = '(F6.4)'
COLORBAR, TITLE=cb_title, RANGE=[min_histo,max_histo],  POSITION=cb_pos3, $
          COLOR=0,DIVISIONS=4,/vertical,charsize = charsize,charthick=charthick

path_w  = '/home/bruce/program/idl/calipso/dzhang/plot/'
fname_w = fname + '_case'
null = TVREAD(filename=path_w + fname_w, /gif, /nodialog)
WDELETE
;STOP
;RETURN

END
