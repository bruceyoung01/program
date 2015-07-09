load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  datadir  = ncargpath("data")
  datafile = datadir + "/cdf/meccatemp.cdf"
;
; Load a file record from the netCDF file
; as a read only data set.
;
  n = addfile(datafile,"r")
  t = n->t(0,:,:)

  type                   = "x11"
  type@wkColorMap        = "rainbow"
  type@wkBackgroundColor = "white"
  type@wkForegroundColor = "black"

  wks = gsn_open_wks(type,"annotation")     ; Open a workstation.
;
; If you don't add this color, your continent colors
; will be white instead of gray.
;
  newindex = NhlNewColor(wks,0.8,0.8,0.8)

;
; Set some resources.
;
  res                     = True
  res@gsnSpreadColors     = True
  res@gsnSpreadColorEnd   = -2
  res@gsnMaximize         = True
  res@gsnAddCyclic        = False

  res@cnLevelSelectionMode= "ManualLevels"
  res@cnMinLevelValF      =  195.0
  res@cnMaxLevelValF      =  328.0
  res@cnLevelSpacingF     = 2.25
  res@cnFillOn            = True
  res@cnLinesOn           = False

  res@lbLabelAutoStride   = True

  res@mpGridAndLimbOn     = False
  res@mpFillDrawOrder     = "PostDraw"

  plot = gsn_csm_contour_map(wks,t,res)
end


