; Code to load in a VIIRS aerosol EDR file and return output as IDL structure
; Many arrays are x,y; some are x,y,z where the z-dimension is a
; spectrally varying quantity (e.g. AOD)
;
; HISTORY
; 05 MAY 2011 A Sayer         Rewritten to account for format change (from
;                             HDF-EOS5 to HDF5), SDS updates, and to read in
;                             global attributes
; 05 JUN 2011 Jingfeng Huang  Rewritten for VIIRS hdf5 handlers

function read_viirs_h5_sds, l2file, sdsname

;print, 'SDS is: ', sdsname

;print, 'l2file is: ', l2file

fid = h5f_open(l2file)
d   = h5d_open(fid,sdsname)
sds = H5D_READ(d)

H5F_CLOSE, fid

; l2 structure to return: contains geometry etc and combined arrays in main structure
;l2  = {sds:sds}

return,sds
;return
end

;Usage:
;L2=read_viirs_h5_sds('/Volumes/data/SeaWiFS/L3M05/DeepBlue-SeaWiFS-0.5_L3M_201012_v002-20110528T104823Z.h5', 'aerosol_optical_thickness_550_land_ocean')
;struct exam: 
;LATS=L2.(0)
;help,L2,/struct

;save,L3M05,filename='/Volumes/data/SeaWiFS/L3M05.sav'
;restore,'/Volumes/data/SeaWiFS/L3M05.sav'
