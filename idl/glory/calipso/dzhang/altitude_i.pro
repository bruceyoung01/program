FUNCTION Altitude_i, i
;*****************************************************
;;// calculate altitude resolution 30m below 8.2km, 60m/8.2-20.2km, 180m/20.2-30.1km, 300m above 30.1km

z=fltarr(583)

FLAG=0

IF (i GE 0) AND (i LE 32) then FLAG=1
IF (i GE 33) AND (i LE 87) then FLAG=2
IF (i GE 88) AND (i LE 287) then FLAG=3
IF (i GE 288) AND (i LE 577) then FLAG=4
IF (i GE 578) AND (i LE 582) then FLAG=5


CASE FLAG OF
	1: 	z = 40.000-0.150-i*0.3

	2:	z = 30.25-(i-33)*0.18-0.24

	3: 	z = 20.29-(i-88)*0.06-0.12

	4: 	z = 8.23-(i-288)*0.03-0.045

	5: 	z = -0.485-(i-578)*0.3-0.165

	else: 	begin
			print, 'input i is out of range (0-582)!'
			break
			end
ENDCASE

return, z
END