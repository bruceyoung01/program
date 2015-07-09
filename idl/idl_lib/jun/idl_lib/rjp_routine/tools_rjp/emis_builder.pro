; This script makes emission inventories using several source gases from 
;
;

pro emis_builder, month, ilmm=ilmm, ijmm=ijmm, inter=inter, $
    NOx=NOx,CO=CO,ISOP=ISOP,C2H6=C2H6,C3H8=C3H8,C2H4=C2H4,C3H6=C3H6,CH3COCH3=CH3COCH3

if n_elements(month) eq 0 then month = 1
if n_elements(ilmm)  eq 0 then ilmm = 72 ; number of nod in longitude
if n_elements(ijmm)  eq 0 then ijmm = 46 ; number of nod in lattitude
if n_elements(inter) eq 0 then inter= 0

  tag = strtrim(string(month),1)

   isea = month/3
   imon = month - 1

if isea eq 4 then isea = 0

;...SETUP FOR INPUT VARIABLES
;...
;...Set the grid for emission inventories
;...Current input emission are on uniform grid with 1x1 grid resolution.

grid = gridgen(360,180,'C')

emlat = reform(grid.latc(0,*))      ; Uniform 1D grid
emlon = reform(grid.lonc(*,0))

emlatb = reform(grid.latb(0,*))
emlonb = reform(grid.lonb(*,0))

fd12 = fltarr(360,180,12)
fd04 = fltarr(360,180,4)

areain = sfcarea(ilmm=360.,ijmm=180.,grid_type='C')

;...SETUP FOR OUTPUT VARIABLES
;...

; setup grid for output (A grid)
;...Y direction
;...Note model starts from 90 S that is center of lowest model grid box and
;...also the lower boundary of that box.
;...Same thing is applied for upper boundary at 90 N
;
;...X direction
;...Note the center of leftmost model box is always 180 W...
grid = gridgen(ilmm,ijmm,'A')

lon2 = grid.lonc  ; Center
lat2 = grid.latc

lon2b = grid.lonb ; Boundary
lat2b = grid.latb

areaout = sfcarea(ilmm=ilmm,ijmm=ijmm,grid_type='A')

;...SETUP for SPECIES

 CO   = fltarr(ilmm,ijmm)
 NOx  = fltarr(ilmm,ijmm,2) ; low and high emission
 ISOP = CO 
 C2H6 = CO
 C3H8 = CO
 C2H4 = CO
 C3H6 = CO
 CH3COCH3 = CO

 dir = '/data/storm2/stone/data4ctm/emission/source'
;===================================================================================
;...Interpolation or averaging will begin here..
;...If the size of output grid is larger than that of input grid then 
;...Use averaging instead of interpolation...

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;..CO {Biomass [galanter] and Fossil fuel [Edgar]}
openr,il,dir+'/co/CO_bio_galanter.dat_mole_360180_12rec_xdr',/xdr,/get 
readu,il,fd12
free_lun,il
fdin = fd12(*,*,imon)

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...BIO CO (moles) for ', month
 bmCO = fdout 

openr,il,dir+'/co/CO_ff_edgar.dat_mole_360180_04rec_xdr',/xdr,/get
readu,il,fd04
free_lun,il
fdin = fd04(*,*,isea)/3. ; Make monthly emission
fdin = fdin * 1.3        ; 30 % increase for fosil fuel [Aprados, personal communication]

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...FF CO (moles) for ', month
 ffCO = fdout
 
openr,il,dir+'/terp/CO.terp_geia.dat_moles_360180_12rec_xdr',/xdr,/get
readu,il,fd12
free_lun,il
fdin = fd12(*,*,imon)

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...TERP CO (moles) for ', month
 tpCO = fdout 

 
 CO = bmCO + ffCO + tpCO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;...NOx {Biomass [galanter], Fossil fuel [Geia], and Soil [Geia]}
openr,il,dir+'/nox/NOx_bio_galanter.dat_moles_360180_12rec_xdr',/xdr,/get
readu,il,fd12
free_lun,il
fdin = fd12(*,*,imon)

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...BIO NOx (moles) for ', month
 bmNOx = fdout

openr,il,dir+'/nox/NOx_ff_geia.dat_moles_360180x02_04rec_xdr',/xdr,/get
readu,il,fd04
fdin = fd04(*,*,isea)/3.

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...FF low NOx (moles) for ', month
 ffNOxl = fdout

readu,il,fd04
free_lun,il
fdin = fd04(*,*,isea)/3.

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...FF high NOx (moles) for ', month
 ffNOxh = fdout
 
openr,il,dir+'/nox/NOx_soil_geia.dat_moles_360180_12rec_xdr',/xdr,/get
readu,il,fd12
free_lun,il
fdin = fd12(*,*,imon)

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...SOIL NOx (moles) for ', month
 soilNOx = fdout
 
 NOx(*,*,0) = bmNOx + ffNOxl + soilNOx
 NOx(*,*,1) = ffNOxh

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;...ISOP {Biogenic [Geia]}
openr,il,dir+'/isop/ISOP_bio_geia.dat_moles_360180_12rec_xdr',/xdr,/get
readu,il,fd12
free_lun,il
TISOP = total(fd12) * 5. * 12.011 / 1.e12  ; Tg C /yr of isoprene
fdin = fd12(*,*,imon)

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...ISOP (moles) for ', month
 ISOP = fdout

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; c = 12.011, h = 1.0079, o = 15.999, n = 14.007
;CH3COCH3 (Acetone) (molecular weight = 58.0794)
; {Biomass [Wang], Biogenic [Wang], and FF [Edgar]}
;...Biomass burning
;...I assume the molar emission ratios of 1.3 % for acetone to CO from 
;...Wang et al.[1998]

 fdout = bmCO * 0.013
 print, total(fdout), '...BIO CH3COCH3 (moles) for ', month
 bmACE = fdout

;...Biogenic emission
;... mwisop = 68.12 (C5H8)
;...
;... based  upon the isoprene emission
;... we calculated total biogenic source for ch3coch3 of 15 Tg C /yr
;... The temporal and spatial distribution of this acetone source is 
;... assumed to that of isoprene.

;; moles -> g C (isoprene)
 fdout = 15. * isop * 5. * 12.011 / TISOP    ; g C (acetone)
 fdout = fdout / (3.*12.011)                 ; g C -> moles
 print, total(fdout), '...BIOGENIC CH3COCH3 (moles) for ', month
 bgACE = fdout

;...Fosil Fuel emission
;...
openr,il,dir+'/nmhc/CH3COCH3_ff_edgar.dat_moles_360180_04rec_xdr',/xdr,/get
readu,il,fd04
free_lun,il
fdin = fd04(*,*,isea)/3.

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...FF CH3COCH3 (moles) for ', month
 ffACE = fdout
 CH3COCH3 = bmACE + bgACE + ffACE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;...NMHC, BIOMASS [Edgar]
;Ethane
openr,il,dir+'/nmhc/C2H6_bio_edgar.dat_mole_360180_12rec_xdr',/xdr,/get
readu,il,fd12
free_lun,il
fdin = fd12(*,*,imon)

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...BIO C2H6 (moles) for ', month
 bmC2H6 = fdout
  
;Propane
openr,il,dir+'/nmhc/C3H8_bio_edgar.dat_mole_360180_12rec_xdr',/xdr,/get
readu,il,fd12
free_lun,il
fdin = fd12(*,*,imon)

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...BIO C3H8 (moles) for ', month
 bmC3H8 = fdout
  
;Ethene
openr,il,dir+'/nmhc/C2H4_bio_edgar.dat_mole_360180_12rec_xdr',/xdr,/get
readu,il,fd12
free_lun,il
fdin = fd12(*,*,imon)

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...BIO C2H4 (moles) for ', month
 bmC2H4 = fdout
  
;Propene
openr,il,dir+'/nmhc/C3H6_bio_edgar.dat_mole_360180_12rec_xdr',/xdr,/get
readu,il,fd12
free_lun,il
fdin = fd12(*,*,imon)

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...BIO C3H6 (moles) for ', month
 bmC3H6 = fdout
  

;...NMHC FF
;Ethane
openr,il,dir+'/nmhc/C2H6_ff_edgar.dat_mole_360180_04rec_xdr',/xdr,/get
readu,il,fd04
free_lun,il
fdin = fd04(*,*,isea)/3.

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...FF C2H6 (moles) for ', month
 ffC2H6 = fdout
  
;Propane
openr,il,dir+'/nmhc/C3H8_ff_edgar.dat_mole_360180_04rec_xdr',/xdr,/get
readu,il,fd04
free_lun,il
fdin = fd04(*,*,isea)/3.

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...FF C3H8 (moles) for ', month
 ffC3H8 = fdout
  
;Ethene
openr,il,dir+'/nmhc/C2H4_ff_edgar.dat_mole_360180_04rec_xdr',/xdr,/get
readu,il,fd04
free_lun,il
fdin = fd04(*,*,isea)/3.

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...FF C2H4 (moles) for ', month
 ffC2H4 = fdout

;Propene
openr,il,dir+'/nmhc/C3H6_ff_edgar.dat_mole_360180_04rec_xdr',/xdr,/get
readu,il,fd04
free_lun,il
fdin = fd04(*,*,isea)/3.

 if (inter eq 1) then begin
  fdout = interh(fdin/areain, emlon, emlat, lon2, lat2)
  fdout = fdout * areaout
 endif else begin
  fdout = aave(fdin, emlonb, emlatb, lon2b, lat2b)
 end
 print, total(fdout), '...FF C3H6 (moles) for ', month
 ffC3H6 = fdout
 
 C2H6 = bmC2H6 + ffC2H6
 C3H8 = bmC3H8 + ffC3H8
 C2H4 = bmC2H4 + ffC2H4
 C3H6 = bmC3H6 + ffC3H6

end
