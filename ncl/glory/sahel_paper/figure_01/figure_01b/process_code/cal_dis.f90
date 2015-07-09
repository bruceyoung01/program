!
!this routine calcultes the distance between two lats and lons on earth
! 

	subroutine cal_dis( flat1, flat2, flon1, flon2, dis)
	  parameter (Re = 6370, rad = 3.1415926/180.)
	  real flat1, flat2, flon2, flon1, dis
	  tmplat1 = flat1*rad
	  tmplat2 = flat2*rad
	  tmplon1 = flon1*rad
	  tmplon2 = flon2*rad
	  a = cos(tmplat1)*(abs(tmplon1-tmplon2));
	  b = abs (tmplat1 - tmplat2);
	  c = acos(cos(a)*cos(b));
	  dis = Re*c
	end  

