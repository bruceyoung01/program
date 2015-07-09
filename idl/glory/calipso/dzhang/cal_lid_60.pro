FUNCTION cal_lid_60, temp_array, array
;;// dliu3@uwyo.edu
;;// convert CAL_LID data to 60m vertical resolution
;;// input  L1_nbin=583
;;// out y_num = (287-88+1)+(577-288+1)/2 ; = 200+290/2=345

XX = size(temp_array)

;print, XX
;waitakey

if XX[0] EQ 2 then begin
	y_num = 345

	array = fltarr(y_num, XX[2])

	array[0:199,*] = temp_array[88:287,*]
	array[200:344,*] = REBIN(temp_array[288:577,*], 145, XX[2])

	return, array
endif

if XX[0] EQ 1 then begin
	y_num = 345

	array = fltarr(y_num)

	array[0:199] = temp_array[88:287]
	array[200:344] = REBIN(temp_array[288:577], 145)

	return, array
endif


END