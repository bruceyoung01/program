; this script will call qqall.pro & allows plotting of multiple plots per page.

seas = 'JUL'

; ljm filename
;open_device, /ps, /portrait, /color, filename='qq1980_2x2.papfig.'+seas+'.ps'
open_device, /ps, /portrait, /color, filename='pretty'
multipanel, cols=1, rows=3;, omargin=[.2,.2]
;multipanel,4

;FOR ORALS FIGURE

;qqpiston, 22,34, 4,  seas; Harvard Forest
;qqpiston, 20,32, 4,  seas; TN Giles & Cove
;qqpiston, 14,32, 4, seas;LA
;qqpiston, 15,33, 4,  seas; UT/AZ/NM/CO
;qqpiston, 20, 34, 4,  seas; MI 
;qqpiston, 20, 33, 4,  seas; KY/N TN
;qqpiston, 19, 34, 4,  seas; N IL, S WI, W IA
;qqpiston, 19, 33, 4,  seas; S IL, W MO, KY/TN/AS corner

qqpiston, 44,67, 2,  seas; Harvard Forest
xyouts, -2.7, 4., 'Western MA, CT, RI (72.5W 42N)', color=1, /data,  charsize=1.5

qqpiston, 38,64, 2,  seas; TN Giles & Cove
xyouts, -2.7, 4., 'Western TN (87.5W 36N)', color=1, /data,  charsize=1.5

;qqpiston, 26,63, 2, seas;  LA

qqpiston, 28,64, 2,  seas; Grand Canyon
xyouts, -2.7, 4., 'Grand Canyon, AZ (112.5W 36N)', color=1, /data,  charsize=1.5

;qqpiston, 39,67, 2,  seas; S MI 
;qqpiston, 39, 64, 2,  seas; KY/N TN
;qqpiston, 37, 67, 2,  seas; N IL, S WI, W IA
;qqpiston, 38, 65, 2,  seas; S IL, W MO, KY/TN/AS corner

;qqpiston, 39, 66, 2, seas; N Indiana
;qqpiston, 39, 65, 2, seas; W KY


;xyouts, .25, 1.01, 'GEOS-CHEM 2x2.5 1-4 pm July 1995 Ozone ', /normal, color=1

close_device

;open_device, /ps, /landscape, /color, filename='qqcheck.ps'
;multipanel, 4
;qqall, 25,65 ; NCA 
;close_device

;qqall, 25,64  ;LA
;qqall, 24,66 ; N CA
;qqall, 24,65  ;San Fran
;qqall, 25,66 ; N CA
;qqall, 24,69 ; OR/WA
;qqall, 24,68  ; OR
;qqall, 28, 63 ; AZ
;qqall, 34, 62 ; TX
;qqall, 37, 65 ; MO,IL
;qqall, 39, 64 ; TN
;qqall, 40, 66 ; OH
;qqall, 39, 65 ; KY
;qqall, 42, 65 ; MD/VA
;qqall, 42, 66 ; PA/MD
;qqall, 45, 68 ; S ME

;qqall, 27,64 ; tip of NV
;qqall, 28,66 ; UT
;qqall, 28,67 ; UT/ID
;qqall, 30,62 ; NM tip
;qqall, 31,66 ; CO
;qqall, 35,67 ; W IA
;qqall, 38, 63 ; AL
;qqall, 38, 64; TN
;qqall, 39, 63; GA

;xyouts, .3, 1.01, ' AIRS Observations and GEOS-CHEM Simulated Summer 1995 Ozone ', /normal, color=1
;
;close_device

;open_device, /ps, /landscape, /color, filename='qqsamp3.ps'
;multipanel, 12

;qqall, 35, 62 ; TX
;qqall, 35, 66 ; NB/KS/MO/IA
;qqall, 37, 66 ; IL
;qqall, 37, 67 ; IL/WI
;qqall, 37, 68 ; WI
;qqall, 40, 60 ; FL
;qqall, 40, 61 ; FL
;qqall, 40, 63 ;GA/SC
;qqall, 40, 64 ; NC/TN
;qqall, 40, 67 ; MI/OH
;qqall, 43, 67 ;  NY/PA/NJ
;qqall, 26,70
;qqall, 44, 67 ; Harvard Forest
;qqall, 37, 61

;xyouts, .3, 1.01, ' AIRS Observations and GEOS-CHEM Simulated Summer 1995 Ozone ', /normal, color=1

;close_device

end
