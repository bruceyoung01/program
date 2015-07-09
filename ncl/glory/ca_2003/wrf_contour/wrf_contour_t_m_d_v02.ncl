
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : PLOT THE CONTOUR PLOT USING WRF/CHEM OUTPUT
; THE STEPS ARE AS FOLLOWING : 
; 1, READ DATA FROM WRF OUTPUT .NC FILE
; 2, PLOT A MAP WITH A SPECIFIED PROJECTION (NOT NATIVE)
; 3, PLOT A CONTOUR OVER A MAP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

; OPEN WRF/CHEM OUTPUT FILE
  a = addfile("/media/disk/data/wrfchem/200805_sepanf/wrfout_d01_2008-05-01_00:00:00_1200sepanf.nc","r")
  b = addfile("/media/disk/data/wrfchem/200805_sepanf/wrfout_d01_2008-05-02_00:00:00_1200sepanf.nc","r")
  c = addfile("/media/disk/data/wrfchem/200805_sepanf/wrfout_d01_2008-05-03_00:00:00_1200sepanf.nc","r")
  d = addfile("/media/disk/data/wrfchem/200805_sepanf/wrfout_d01_2008-05-04_00:00:00_1200sepanf.nc","r")
  e = addfile("/media/disk/data/wrfchem/200805_sepanf/wrfout_d01_2008-05-05_00:00:00_1200sepanf.nc","r")
  f = addfile("/media/disk/data/wrfchem/200805_sepanf/wrfout_d01_2008-05-06_00:00:00_1200sepanf.nc","r")
  g = addfile("/media/disk/data/wrfchem/200805_sepanf/wrfout_d01_2008-05-07_00:00:00_1200sepanf.nc","r")
  h = addfile("/media/disk/data/wrfchem/200805_sepanf/wrfout_d01_2008-05-08_00:00:00_1200sepanf.nc","r")
  i = addfile("/media/disk/data/wrfchem/200805_sepanf/wrfout_d01_2008-05-09_00:00:00_1200sepanf.nc","r")
  j = addfile("/media/disk/data/wrfchem/200805_sepanf/wrfout_d01_2008-05-10_00:00:00_1200sepanf.nc","r")
  aa = addfile("/media/disk/data/wrfchem/200805_sepaf/wrfout_d01_2008-05-01_00:00:00_1200sepaf.nc","r")
  bb = addfile("/media/disk/data/wrfchem/200805_sepaf/wrfout_d01_2008-05-02_00:00:00_1200sepaf.nc","r")
  cc = addfile("/media/disk/data/wrfchem/200805_sepaf/wrfout_d01_2008-05-03_00:00:00_1200sepaf.nc","r")
  dd = addfile("/media/disk/data/wrfchem/200805_sepaf/wrfout_d01_2008-05-04_00:00:00_1200sepaf.nc","r")
  ee = addfile("/media/disk/data/wrfchem/200805_sepaf/wrfout_d01_2008-05-05_00:00:00_1200sepaf.nc","r")
  ff = addfile("/media/disk/data/wrfchem/200805_sepaf/wrfout_d01_2008-05-06_00:00:00_1200sepaf.nc","r")
  gg = addfile("/media/disk/data/wrfchem/200805_sepaf/wrfout_d01_2008-05-07_00:00:00_1200sepaf.nc","r")
  hh = addfile("/media/disk/data/wrfchem/200805_sepaf/wrfout_d01_2008-05-08_00:00:00_1200sepaf.nc","r")
  ii = addfile("/media/disk/data/wrfchem/200805_sepaf/wrfout_d01_2008-05-09_00:00:00_1200sepaf.nc","r")
  jj = addfile("/media/disk/data/wrfchem/200805_sepaf/wrfout_d01_2008-05-10_00:00:00_1200sepaf.nc","r")


; OPEN A WORKSTATION AND CHOOSE COLORMAP
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks  = gsn_open_wks(type,"1plt_wrf_contour_t_m_d_2008-05-08")
  gsn_define_colormap(wks,"BlWhRe")

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res              = True

; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection      = "CylindricalEquidistant"
  res@mpCenterRotF      = 0.0
  res@mpGridAndLimbOn   = True
  res@mpGridLatSpacingF = 5.0
  res@mpGridLonSpacingF = 5.0
  res@mpLimitMode       = "latlon"
  res@mpMinLatF         = 10.0
  res@mpMaxLatF         = 45.0
  res@mpMinLonF         = -115.0
  res@mpMaxLonF         = -65.0

; COLOR OF CONTINIENTAL OUTLINES
  res@mpOutlineOn                 = True
  res@mpGeophysicalLineColor      = "White"
  res@mpNationalLineColor         = "White"
  res@mpUSStateLineColor          = "White"
  res@mpGridLineColor             = "White"
  res@mpLimbLineColor             = "White"
  res@mpPerimLineColor            = "White"
  res@mpGeophysicalLineThicknessF = 2.0
  res@mpGridLineThicknessF        = 1.5
  res@mpLimbLineThicknessF        = 2.0
  res@mpNationalLineThicknessF    = 2.0
  res@mpUSStateLineThicknessF     = 2.0
  res@mpGridLineDashPattern       = 2
  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"

; TURN ON MAP TICKNARKS
  res@pmTickMarkDisplayMode       = "always"
; plot_base                       = gsn_csm_map(wks,res)

; MAXIMIZE PLOT IN FRAME
  res@gsnMaximize = True
; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic= False
; SET UP THE FEATRUED TITLE
  res@gsnLeftString                = "2M Temperature "
  res@gsnStringFontHeightF         = 0.02
  res@gsnRightStringOrthogonalPosF = 0.02
  res@gsnLeftStringOrthogonalPosF  = 0.02

; COLOR PLOT DEDIRED
  res@cnFillOn       = True
; TURN OFF CONTOUR LINES
  res@cnLinesOn      = False
; TURN OFF CONTOUR LABELS
  res@cnLineLabelsOn = False

; SET UP COLOR MAP AND LABEL
  res@gsnSpreadColors        = True
  res@gsnSpreadColorStart    = 0
  res@gsnSpreadColorEnd      = 900
  res@cnInfoLabelOn          = True
  res@cnInfoLabelFontHeightF = 0.01

  res@cnLevelSelectionMode     = "ManualLevels"
  res@cnMinLevelValF           = -3.0
  res@cnMaxLevelValF           = 3.0
  res@cnLevelSpacingF          = 0.2

; SET UP LABEL BAR
  res@pmLabelBarWidthF       = 0.6
  res@pmLabelBarHeightF      = 0.08
  res@lbLabelFontHeightF     = 0.013
  res@lbLabelStride          = 2
  res@lbBoxLinesOn           = False


; PLOT THE CONTOUR OVER THE CE MAP
  do it = 0, 23, 3

; READ PM2.5 DATA FROM WRF/CHEM OUTPUT FILE AND SET XLAT AND XLONG AS THE ATTRIBUTE OF PM25
   times       = a->Times(it,:)
   t2a         = a->T2(it,:,:)
   t2b         = b->T2(it,:,:)
   t2c         = c->T2(it,:,:)
   t2d         = d->T2(it,:,:)
   t2e         = e->T2(it,:,:)
   t2f         = f->T2(it,:,:)
   t2g         = g->T2(it,:,:)
   t2h         = h->T2(it,:,:)
   t2i         = i->T2(it,:,:)
   t2j         = j->T2(it,:,:)
   t2aa        = aa->T2(it,:,:)
   t2bb        = bb->T2(it,:,:)
   t2cc        = cc->T2(it,:,:)
   t2dd        = dd->T2(it,:,:)
   t2ee        = ee->T2(it,:,:)
   t2ff        = ff->T2(it,:,:)
   t2gg        = gg->T2(it,:,:)
   t2hh        = hh->T2(it,:,:)
   t2ii        = ii->T2(it,:,:)
   t2jj        = jj->T2(it,:,:)

   t2  = (t2a+t2b+t2c+t2d+t2e+t2f+t2g+t2h+t2i+t2j-(t2aa+t2bb+t2cc+t2dd+t2ee+t2ff+t2gg+t2hh+t2ii+t2jj))/10.
   t2@lat2d         = a->XLAT(it,:,:)
   t2@lon2d         = a->XLONG(it,:,:)
   t2@description   = "2M Temperature"
   t2@units         = "K"
   res@tiMainString = "REAL TIME-WRF/CHEM                "+times
   res@tiMainFontHeightF      = 0.02
   res@lbTitleString          = t2@description + "  " + "(" + t2@units + ")"
   res@lbTitleFontHeightF     = 0.015
   res@lbTitlePosition        = "Bottom"
   map = gsn_csm_contour_map(wks,t2(:,:),res)
  end do


end
