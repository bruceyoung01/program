Function dozier_calculation_fast, xxsza, xxvza, xxraz, xxir396, xxir11, rad4b, rad11b

;Start DOZIER calculations using lookup table from SBDART

;read in binary lookup tables
lu4=fltarr(4206600)
openr, 10, 'lookup_table4.dat'		
readu, 10, lu4
close, 10

lu11=fltarr(4206600)
openr, 10, 'lookup_table11.dat'		
readu, 10, lu11
close, 10

;number of elements of each variable
nv=(n_elements(lu4)/5)-1

;get lookup data
sza4=lu4(0:nv)
btemp4=lu4(nv+1:2*nv+1)
rangle4=lu4(2*nv+2:3*nv+2)
vangle4=lu4(3*nv+3:4*nv+3)
lrad4=lu4(4*nv+4:5*nv+4)

sza11=lu11(0:nv)
btemp11=lu11(nv+1:2*nv+1)
rangle11=lu11(2*nv+2:3*nv+2)
vangle11=lu11(3*nv+3:4*nv+3)
lrad11=lu11(4*nv+4:5*nv+4)

;Simulated temperatures
stemp=[280,290,300,310,320,330,340,350,360,370,380,390,400,410,420,430,440,$
450,460,470,480,490,500,510,520,530,540,550,560,570,580,590,600,610,$
620,630,640,650,660,670,680,690,700,710,720,730,740,750,760,770,780,$
790,800,810,820,830,840,850,860,870,880,890,900,910,920,930,940,950,$
960,970,980,990,1000,1010,1020,1030,1040,1050,1060,1070,1080,1090,1100,$
1110,1120,1130,1140,1150,1160,1170,1180,1190,1200,1210,1220,1230,1240,$
1250,1260,1270,1280,1290,1300,1310,1320,1330,1340,1350,1360,1370,1380,$
1390,1400,1410,1420,1430,1440,1450,1460,1470,1480,1490,1500]
nt=n_elements(stemp)
;------------------------------------------------------------------
;actual Dozier step
	;time1 = systime()	 
    	thresmin=10000

	for t=10,nt-1 do begin;nt-1
	;print, stemp(t)

	    ;use lookup data to get respective radiances
	    ;for the fire (target) term			 
	    lsza1=closest(xxsza,sza4,value=val)
	    lsza=val(0)

	    lvza1=closest(xxvza,vangle4,value=val)
	    lvza=val(0)

	    lraz1=closest(xxraz,rangle4,value=val)
	    lraz=val(0)	

	    retr=where(sza4 eq lsza and vangle4 eq lvza and $
	     rangle4 eq lraz and btemp4 eq stemp(t))

		 ;get radiance 
		 ;the other varibles are the same for 4 and 11 um
		 ; so we can use the same result
		 ptfire4=lrad4(retr)
		 ptfire11=lrad11(retr)

	    ;----------------------------------------------------------	
	    ;solve Dozier equations (residual method)
	      ;using a modified version of the method by Shephard and Kennelly (2003)

	    ;equation
	      ;solve for fire temp
	      ;(xxir396-rad4b)/(ptfire4-rad4b)=(xxir11-rad11b)/(ptfire11-rad11b) 				
		;leftside  = .95*((xxir396-rad4b)/(ptfire4-rad4b))
		;rightside = .97*((xxir11-rad11b)/(ptfire11-rad11b))
		leftside  = (.95*(xxir396-rad4b)/(ptfire4-rad4b))
		rightside = (.97*(xxir11-rad11b)/(ptfire11-rad11b))

	    ;get residual	
		resid=leftside-rightside

	    threshold=abs(resid)

		;get fire temp and area fraction based on lowest residual
		if threshold lt thresmin then begin
		    thresmin  =  threshold
		    firerad4  =  ptfire4
		    firerad11 =  ptfire11

		    ;fire temp
		      tfire = stemp(t)

		    ;Solve for fire area fraction (p)			    
		      area_fract4 = leftside							
		      area_fract11 = rightside
    	    	      area_fract = mean([area_fract4,area_fract11])	
		      ;print,[resid,area_fract4,area_fract11, tfire]	   
		endif		
	endfor
;print, 	[xxir396,rad4b,xxir11,rad11b]
;print, area_fract4, area_fract11	
;print, ptfire4,ptfire11
ddata=[area_fract,tfire]
;print, ddata


;time2 = systime()
;print, 'start time ', time1 , ' end time ', time2
			
return, ddata		
END
