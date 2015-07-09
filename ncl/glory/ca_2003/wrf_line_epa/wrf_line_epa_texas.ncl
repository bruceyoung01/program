
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : 
; PLOT THE RELATIONSHIP BETWEEN SIMULATION AND EPA GROUND_BASED 
; OBSERVATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

;-----------------------EPA SITES-------------------------------------
; READ DATA INTO A BIG 1D STRING ARRAY
  fname ="/mnt/sdc/data/epa/epa_data/PM25_DATA/PM25_Simplified_Data/Simple_New_RD_501_88502_2008-0.txt"
  fname1="/mnt/sdc/data/epa/epa_data/PM25_DATA/PM25_Simplified_Data/Simple_new_site_monitor.txt"
  data=asciiread(fname,-1,"string")
  data1=asciiread(fname1,-1,"string") 
; COUNT THE NUMBER OF FIELDS, JUST TO SHOW IT CAN BE DONE
  nfields=str_fields_count(data(1)," ")
  print("number of fields = "+nfields) 
  nfields1=str_fields_count(data1(1)," ")
  print("number of fields1 = "+nfields1)
  
; SKIP THE FIRST ROW OF "DATA" BECAUSE IT'S JUST A HEADER LINE
; USE A SPACE(" ") AS A DELIMETER IN STR_GET_FIELD. THE FIRST FIELD
; IS FIELD=1 (UNLIKE STR_GET_COLS, IN WHICH THE FIRST COLUMN IS COLUMN=0)
  state  =stringtoint(str_get_field(data(1::),1," "))
  county =stringtoint(str_get_field(data(1::),2," "))
  site   =stringtoint(str_get_field(data(1::),3," "))
  yr     =stringtoint(str_get_field(data(1::),4," "))
  mn     =stringtoint(str_get_field(data(1::),5," "))
  dd     =stringtoint(str_get_field(data(1::),6," "))
  time   =stringtoint(str_get_field(data(1::),7," "))
  epapm25=stringtofloat(str_get_field(data(1::),8," "))
  
  astate =stringtoint(str_get_field(data1(1::),2," "))
  acounty=stringtoint(str_get_field(data1(1::),3," "))
  asite  =stringtoint(str_get_field(data1(1::),4," "))
  lat    =stringtofloat(str_get_field(data1(1::),5," "))
  lon    =stringtofloat(str_get_field(data1(1::),6," "))

; OPEN WRF/CHEM OUTPUT FILE
  a = addfile("/media/disk/data/wrfchem/200805_sepanf/wrfout_d01_2008-05-09_00:00:00_1200sepanf.nc","r")

; OPEN A WORKSTATION AND CHOOSE COLORMAP
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks = gsn_open_wks(type,"1plt_wrf_line_pm25_i_2008-05-09_sepanf_v03_3_texas")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

; DO TIME LOOP
  do it = 0, 23, 3

; PLOT THE CONTOUR OVER THE CE MAP
; READ PM2.5 DATA FROM WRF/CHEM OUTPUT FILE AND SET XLAT AND XLONG AS THE ATTRIBUTE OF PM25
   times      = a->Times(it,:)
   pm25       = a->PM2_5_DRY(it,0,:,:)
   pm25@lat2d = a->XLAT(it,:,:)
   pm25@lon2d = a->XLONG(it,:,:)
   wlat       = a->XLAT(it,:,:)
   wlon       = a->XLONG(it,:,:)
   print(times)

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res = True
  res@xyDashPattern = 0
  res@xyMarkLineMode= (/"MarkLines","MarkLines"/)
  res@xyMarkers     = (/16,16/)
  res@xyMarkerSizes = (/3,3/)
  res@xyMarkerColors= (/"Blue","Red"/)
  res@xyLineColors  = (/"Blue","Red"/)
; SET TITLE RESOURCES
  res@tiMainString  = "WRF/CHEM - EPA    " + times
  res@tiXAxisString = "Site"
  res@tiYAxisString = "PM2.5 Mass Concentration (ug/m^3)"

; JUDGE IF THE THERE ARE EPA STATION OBSERVATION AT THIS TIME
   yyr=stringtoint(str_get_cols(times,0,3))
   mmn=stringtoint(str_get_cols(times,5,6))
   ddd=stringtoint(str_get_cols(times,8,9))
   ttime=stringtoint(str_get_cols(times,11,12)+"00")

; SELECT EPA  SITE DATA
; FIND THE INDEX THAT MATCHES THE SPECIFIED TIME
   location=ind(mn.eq.mmn.and.dd.eq.ddd.and.time.eq.ttime)

; PM25 DATA AT THE SPECIFIED TIME
   ppm=epapm25(location)
   sstate=state(location)
   ccounty=county(location)
   ssite=site(location)
   count=50
   x   =ispan(1,count,1)
   tppm=new((/2,count/),float,-999)
   llat=new((/count/),float,-999)
   llon=new((/count/),float,-999)
   lppm=new((/count/),float,-999)
   eppm=new((/count/),float,-999)
   llat@_FillValue=-999
   llon@_FillValue=-999
   index=0
   dim=dimsizes(wlat)
   ssum=0
   do i=0,count-1
     index=ind(astate.eq.sstate(i) .and. \
               acounty.eq.ccounty(i) .and. \
               asite.eq.ssite(i))
     if(index.eq.0)then
       print("No Match Found")
     end if

     if(index.gt.0)then
       llat(i)=lat(index(0))
       llon(i)=lon(index(0))
       print(llat(i))
       print(llon(i))
       if(llat(i).gt.25.and.llat(i).lt.35.and. \
          llon(i).gt.-115.and.llon(i).lt.-85)then
       eppm(ssum) = ppm(i)
       print(ssum)
       do j=0,dim(0)-2
        do k=0,dim(1)-2
         if(llat(i).gt.wlat(j,k).and.llat(i).lt.wlat(j+1,k+1).and. \
            llon(i).gt.wlon(j,k).and.llon(i).lt.wlon(j+1,k+1))
          lppm(ssum)=pm25(j,k)
         end if
        end do
       end do
       end if
       ssum = ssum + 1
     end if
    end do ; END OF I LOOP
    tppm(0,:)=eppm(:)
    tppm(1,:)=lppm(:)
    plot=gsn_csm_xy(wks,x,tppm,res)
    delete(location)
    delete(x)
    delete(tppm)
    delete(eppm)
    delete(lppm)
    delete(ppm)
    delete(sstate)
    delete(ccounty)
    delete(ssite)
    delete(llat)
    delete(llon)
    delete(wlat)
    delete(wlon)
    delete(res)
    frame(wks)
  end do ; END OF IT LOOP
end
