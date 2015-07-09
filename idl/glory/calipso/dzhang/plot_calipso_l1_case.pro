;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; THIS ROUTINE IS FROM DAMAO ZHANG ORIGINALLY. MODIFIED BY BRUCE ON   !
; SEP 13 2011                                                         !
; MODIFICATION :                                                      !
; (1), SPECIFY WHICH EXACT REGION TO BE USED TO PLOT, COMPARING TO    !
;      PLOTTING THE WHOLE TRACK.                                      !
; (2), MODIFY THE COLOR TABLE TO THE SAME AS CALIPSO OFFICIAL IMAGE   !
; (3), FOR LEVEL 1 DAY DATA, REVERSE THE ARRAY TO BE CONSISTENT WITH  !
;      CALIPSO LEVEL 2 DATA. (BRUCE 11/15/2011)                       !
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


;PRO plot_calipso_l1_case

@L1_COMMON
@./process_day.pro

!P.FONT  = 1
path     = '/home/bruce/sshfs/pfw/satellite/CALIPSO/sahel/CAL_LID_L1-ValStage1-V3-01/'
filelist = 'CAL_LID_L1-ValStage1-V3-01_02_smallnn'

process_day, path + filelist, fname

; COUNT # OF FILENAMES TO BE USED
OPENR, 11, path + filelist
filename = STRARR(N_ELEMENTS(fname))
oneline  = ' '
i = 0
WHILE (NOT EOF(11) ) DO BEGIN
 READF, 11, oneline
 filename(i) = oneline
 i = i + 1
ENDWHILE
CLOSE, 11
nfile = i

; DEFINE THE STUDY REGION AND HEIGHT
minh  = 0.0
maxh  = 20.0
minlat=-15.0
maxlat= 35.0
minlon=-25.0
maxlon= 45.0

; DO THE DAY LOOP
FOR iday = 0, nfile-1 DO BEGIN
 read_hdf_l1,path,fname(iday)
 d_or_n = STRMID(fname(iday), 47, 1)
 PRINT, iday, d_or_n
 L1_nbin = 583
 CAL_ALT = FLTARR(L1_nbin)
 FOR i=0, L1_nbin-1 DO BEGIN
  CAL_ALT[i] = altitude_i(i)
 ENDFOR

 L1_DEP_532       = L1_PER_BKS_532/(L1_TOT_BKS_532 - L1_PER_BKS_532)

 CAL_HGT_60       = cal_lid_60(CAL_ALT)
 CAL_TAB532_60    = cal_lid_60(L1_TOT_BKS_532)
 CAL_TAB1064_60   = cal_lid_60(L1_BKS_1064)
 CAL_DEP532_60    = cal_lid_60(L1_DEP_532)
 cal_height_60    = CAL_HGT_60
 lidar_bs_60      = CAL_TAB532_60
 lidar_bs64_60    = CAL_TAB1064_60
 lidar_dep_60     = CAL_DEP532_60
 n_cal_60         = N_ELEMENTS(cal_height_60)
 FOR i = 0, n_cal_60 -1 DO BEGIN
  lidar_bs_60[n_cal_60 -1 - i,*]        = CAL_TAB532_60[i,*]
  lidar_bs64_60[n_cal_60-1-i,*]         = CAL_TAB1064_60[i,*]
  lidar_dep_60[n_cal_60 -1 - i,*]       = CAL_DEP532_60[i,*]
  cal_height_60[n_cal_60 -1 - i]        = CAL_HGT_60[i]
 ENDFOR
 i1    = WHERE(L1_LAT GT minlat AND L1_LAT LT maxlat AND $
               L1_LON GT minlon AND L1_LON LT maxlon)
 n_cal = N_ELEMENTS(CAL_ALT)
 
 FOR i = 0, n_cal_60 - 2 DO BEGIN
  IF((cal_height_60[i] LT maxh) AND (cal_height_60[i+1] GE maxh)) THEN BEGIN
   cal_ih2 = i
  ENDIF
  IF((cal_height_60[i] LT minh) AND (cal_height_60[i+1] GE minh)) THEN BEGIN
   cal_ih1 = i
  ENDIF
 ENDFOR

; DEFINE COLOR TABLE, WHICH IS THE SAME AS THE CALIPSO IMAGE BROWSE ONLINE.
 r = [  0,  0, 24, 24, 24, 24, 24, 50, 16, 34, $
      255,255,238,255,255,238,205,255,255,238, $
       26, 41, 77, 89,102,115,127,140,153,166, $
      179,191,204,252]
 g = [  0,  0,116,116,116,116,116,205, 78,139, $
      193,193,180,193, 69, 64, 55, 62, 62,130, $
       26, 41, 77, 89,102,115,127,140,153,166, $
      179,191,204,252]
 b = [139,139,205,205,205,205,205, 50,139, 34, $
       37, 37, 34, 37,  0,  0,  0,150,150,238, $
       26, 41, 77, 89,102,115,127,140,153,166, $
      179,191,204,252]
 ncolor = N_ELEMENTS(r)
 TVLCT,r,g,b
 WINDOW,/free,xsize=1200,ysize=600,/pixmap
 PLOT,FLTARR(1),/nodata, background=!d.n_colors-1 ; clear background

 charsize       = 2.0
 charthick      = 3.0
 thick          = 2.0
 case1_lidar_bs = FLTARR(cal_ih2-cal_ih1, N_ELEMENTS(i1))
 lidar_bs_60temp= FLTARR(N_ELEMENTS(i1))
 LI_LAT1        = FLTARR(N_ELEMENTS(i1))
 RLI_LAT1       = FLTARR(N_ELEMENTS(i1))
 L1_SURF_ELEV1  = FLTARR(N_ELEMENTS(i1))
 RL1_SURF_ELEV1 = FLTARR(N_ELEMENTS(i1))
 FOR j = 0, cal_ih2-cal_ih1-1 DO BEGIN
  lidar_bs_60temp      = lidar_bs_60[j,i1(0):i1(N_ELEMENTS(i1)-1)]
  case1_lidar_bs(j,*)  = lidar_bs_60temp
 ENDFOR
;-----------------------------------------------------------------------
; FOR DAY TIME DATA, CALIPSO PATHWAY IS FROM SOUTH TO NORTH, WHEREVER, ;
; FOR NIGHT TIME DATA, CALIPSO PATHWAY IS FROM NORTH TO SOUTH.         ;
; SO IN ORDER TO KEEP THE SAME PATHWAY EACH OTHER, CALIPSO DAY TIME    ;
; DATA SHOULD BE REVERSED. SO THAT BOTH OF DAY AND NIGHT DATA CAN BE   ;
; USED TO COMPARE WITH WRFCHEM VERTICAL PROFILE.                       ;
;-----------------------------------------------------------------------
 IF (d_or_n EQ 'D') THEN BEGIN
  case1_lidar_bs= REVERSE(case1_lidar_bs, 2)
 ENDIF
 temp_array     = TRANSPOSE(case1_lidar_bs)
 cb_title       = 'TAB 532 km!u-1!n sr!u-1!n'
 min_histo      = 0.0
 max_histo      = 0.1
 image          = BYTSCL(temp_array,min=min_histo,max=max_histo)
 image_pos      = position_get(1,1,0.10,0.10,0.82,0.95,0.,0.0)
 cb_pos         = position_get(1,1,0.90,0.10,0.92,0.95,0.,0.05)
 image_pos1     = image_pos[0,0,*] & cb_pos1=cb_pos[0,0,*]
 ticknames      = ['1.0E-4', '2.0', '3.0', '4.0', '5.0', '6.0', '7.0', '8.0', '9.0', $
                   '1.0E-3', '1.5', '2.0', '2.5', '3.0', '3.5', '4.0', $
                   '4.5', '5.0', '5.5', '6.0', '6.5', '7.0', '7.5', '8.0', $
                   '1.0E-2', '2.0', '3.0', '4.0', '5.0', '6.0', '7.0', '8.0', '9.0', '1.0E-1', ' ']
 x_title        = ''
 y_title        = 'Altitude (km)'
 xtick          = [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' ,' ' ,' ',' ']

 tvimage, image, position = image_pos1
 nxmajor = 5.
 space   = FIX(N_ELEMENTS(i1)/nxmajor)
 format  = '(F6.2)'
 XL1_LAT = STRING(L1_LAT, FORMAT=format)
 XL1_LON = STRING(L1_LON, FORMAT=format)
 L1_LAT1       = L1_LAT[i1(0):i1(N_ELEMENTS(i1)-1)]
 L1_SURF_ELEV1 = L1_SURF_ELEV[i1(0):i1(N_ELEMENTS(i1)-1)]
 RL1_LAT1      = REVERSE(L1_LAT1)
 RL1_SURF_ELEV1= REVERSE(L1_SURF_ELEV1)

; PLOT THE CALIPSO LEVEL 1 IAMGE
 IF (d_or_n EQ 'N') THEN BEGIN
 PLOT,/nodata, /noerase, FLTARR(1),color = 0,position = image_pos1,$
 yrange=[minh,maxh], yticks = 4, yminor = 5, ytitle=y_title, $
 xrange=[L1_LAT[i1(0)],L1_LAT[i1(N_ELEMENTS(i1)-1)]], xticks = 5, xminor = 2, $
 xtitle=x_title, xstyle = 1, xtickname = xtick,charsize = charsize,charthick = charthick,$
 xthick = 2.0,ythick = 2.0,ystyle = 1
 OPLOT, L1_LAT1, L1_SURF_ELEV1, $
        THICK = thick, color = 170
 PRINT, d_or_n
 XYOUTS, L1_LAT[i1(0)]-0.1*(L1_LAT[i1(N_ELEMENTS(i1)-1)]-L1_LAT[i1(0)]), -1, 'Lat ', $
         charsize = charsize,charthick = charthick,color = 0
 XYOUTS, L1_LAT[i1(0)]-0.1*(L1_LAT[i1(N_ELEMENTS(i1)-1)]-L1_LAT[i1(0)]), -2, 'Lon ', $
         charsize = charsize,charthick = charthick,color = 0
 FOR j = 0, nxmajor DO BEGIN
  XYOUTS, L1_LAT[i1(0)+j*space]-0.03*(L1_LAT[i1(N_ELEMENTS(i1)-1)]-L1_LAT[i1(0)]), -1, $
          XL1_LAT[i1(0)+j*space], charsize = charsize,charthick = charthick,color = 0
  XYOUTS, L1_LAT[i1(0)+j*space]-0.03*(L1_LAT[i1(N_ELEMENTS(i1)-1)]-L1_LAT[i1(0)]), -2, $
          XL1_LON[i1(0)+j*space], charsize = charsize,charthick = charthick,color = 0
 ENDFOR
 ENDIF
 IF (d_or_n EQ 'D') THEN BEGIN
 PLOT,/nodata, /noerase, FLTARR(1),color = 0,position = image_pos1,$
 yrange=[minh,maxh], yticks = 4, yminor = 5, ytitle=y_title, $
 xrange=[L1_LAT[i1(N_ELEMENTS(i1)-1)],L1_LAT[i1(0)]], xticks = 5, xminor = 2, $
 xtitle=x_title, xstyle = 1, xtickname = xtick,charsize = charsize,charthick = charthick,$
 xthick = 2.0,ythick = 2.0,ystyle = 1
 OPLOT, RL1_LAT1, RL1_SURF_ELEV1, $
        THICK = thick, color = 170
 XYOUTS, L1_LAT[i1(N_ELEMENTS(i1)-1)]+0.1*(L1_LAT[i1(N_ELEMENTS(i1)-1)]-L1_LAT[i1(0)]), -1, 'Lat ', $
         charsize = charsize,charthick = charthick,color = 0
 XYOUTS, L1_LAT[i1(N_ELEMENTS(i1)-1)]+0.1*(L1_LAT[i1(N_ELEMENTS(i1)-1)]-L1_LAT[i1(0)]), -2, 'Lon ', $
         charsize = charsize,charthick = charthick,color = 0
 FOR j = 0, nxmajor DO BEGIN
  XYOUTS, L1_LAT[i1(N_ELEMENTS(i1)-1)-j*space]+0.03*(L1_LAT[i1(N_ELEMENTS(i1)-1)]-L1_LAT[i1(0)]), -1, $
          XL1_LAT[i1(N_ELEMENTS(i1)-1)-j*space], charsize = charsize,charthick = charthick,color = 0
  XYOUTS, L1_LAT[i1(N_ELEMENTS(i1)-1)-j*space]+0.03*(L1_LAT[i1(N_ELEMENTS(i1)-1)]-L1_LAT[i1(0)]), -2, $
          XL1_LON[i1(N_ELEMENTS(i1)-1)-j*space], charsize = charsize,charthick = charthick,color = 0
 ENDFOR
 ENDIF

 COLORBAR, TITLE=cb_title, POSITION=cb_pos1, MINOR=1, $
           COLOR=0, NCOLOR=ncolor,DIVISIONS=ncolor,/vertical, $
           charsize = charsize,charthick=charthick, $
           TICKNAMES = ticknames
 path_w  = '/home/bruce/program/idl/calipso/dzhang/plot/'
 fname_w = fname(iday) + '_case'
 null = TVREAD(filename=path_w + fname_w, /gif, /nodialog)
 WDELETE
ENDFOR ; END OF DAY LOOP
END
