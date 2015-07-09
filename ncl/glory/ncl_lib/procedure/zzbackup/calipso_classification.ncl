; $ID: calipso_classification.ncl V01 01/26/2012 10:44 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calipso_classification IS USED TO CLASSIFY AEROSOL AND CLOUD 
;  VERTICAL DISTRIBUTION INTO DIFFERENT TYPES. 
;  CURRENTLY 7 TYPES (FROM TOP TO BOTTOM):
;  (0 ) N/A
;  (1 ) N/A-AEROSOL-N/A
;  (2 ) N/A-AEROSOL-CLOUD-N/A
;  (3 ) N/A-CLOUD-N/A
;  (4 ) N/A-CLOUD-AEROSOL-N/A
;  (5 ) N/A-CLOUD-AEROSOL-CLOUD-N/A
;  (6 ) N/A-CLOUD-AEROSOL-CLOUD-N/A
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir         (string) : DIRECTORY OF CALIPSO DATA                 [---]
;  (2 ) filelist    (string) : FILE NAMES LIST OF CALIPSO DATA           [---]
;  (3 ) minlat      (float)  : MINIMUM LATITUDE OF SELECTED REGION       [deg]
;  (4 ) maxlat      (float)  : MAXIMUM LATITUDE OF SELECTED REGION       [deg]
;  (5 ) minlon      (float)  : MINIMUM LONGITUDE OF SELECTED REGION      [deg]
;  (6 ) maxlon      (float)  : MAXIMUM LONGITUDE OF SELECTED REGION      [deg]
;  (7 ) n_layer     (integer): TOTAL # OF LAYERS FROM BOTTOM TO TOP OF 
;                              CALIPSO LEVEL 2 PRODUCTS                  [---]
;  (8 ) n_old_layer (integer): TOTAL # OF LAYERS FROM BOTTOM TO 19.8KM OF 
;                              CALIPSO LEVEL 2 PRODUCTS                  [---]
;  (9 ) n_new_layer (integer): TOTAL # OF NEW DEFINED LAYERS FROM 0.0KM TO 
;                              19.8KM OF CALIPSO LEVEL 2 PRODUCTS        [---]
;  (10) stride      (integer): THE STRIDE OF OLD LAYER TO NEW LAYER      [---]
;  (11) oheight     (float)  : ORIGINAL VERTICAL LAYERS OF CALIPSO LEVEL 2
;                              PRODUCTS                                  [---]
;  (12) str         (string) : ABBREVIATION OF string                    [---]
;  (13) bv1         (float)  : BAD VALUE FOR FLOAT(-599.94)              [---]
;  (14) bv2         (float)  : BAD VALUE FOR FLOAT                       [---]
;  (15) bv3         (integer): BAD VALUE FOR INTEGER                     [---]
;  (16) sn          (float)  : SELECTED DATA OF TYPE (N)                 [---]
;  (17) in          (integer): # OF SELECTED DATA OF TYPE (N)            [---]
;  (18) snan        (float)  : SELECTED DATA OF TYPE (NAN)               [---]
;  (19) inan        (integer): # OF SELECTED DATA OF TYPE (NAN)          [---]
;  (20) snacn       (float)  : SELECTED DATA OF TYPE (NACN)              [---]
;  (21) inacn       (integer): # OF SELECTED DATA OF TYPE (NACN)         [---]
;  (22) sncn        (float)  : SELECTED DATA OF TYPE (NCN)               [---]
;  (23) incn        (integer): # OF SELECTED DATA OF TYPE (NCN)          [---]
;  (24) sncan       (float)  : SELECTED DATA OF TYPE (NCAN)              [---]
;  (25) incan       (integer): # OF SELECTED DATA OF TYPE (NCAN)         [---]
;  (26) sncacn      (float)  : SELECTED DATA OF TYPE (NCACN)             [---]
;  (27) incacn      (integer): # OF SELECTED DATA OF TYPE (NCACN)        [---]
;  (28) sncacan     (float)  : SELECTED DATA OF TYPE (NCACAN)            [---]
;  (29) incacan     (integer): # OF SELECTED DATA OF TYPE (NCACAN)       [---]
;  (30) tssdim      (integer): TOTAL # OF SELECTED DATA                  [---]
;  (31) fnttype     (float)  : FREQUENCY OF EACH TYPE                    [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/26/2012)
;******************************************************************************

undef("calipso_classification")
procedure calipso_classification(dir     :string, filelist   :string, \ ; INPUT
                                 minlat  :float,  maxlat     :float,  \ ; INPUT
                                 minlon  :float,  maxlon     :float,  \ ; INPUT
                                 n_layer :integer,n_old_layer:integer,\ ; INPUT
                                 n_new_layer:integer,stride  :integer,\ ; INPUT
                                 oheight :float,  str        :string, \ ; INPUT
                                 bv1     :float,  bv2        :float,  \ ; INPUT
                                 bv3     :integer,                    \ ; INPUT
                                 sn      :float,  in         :integer,\ ; OUTPUT
                                 snan    :float,  inan       :integer,\ ; OUTPUT
                                 snacn   :float,  inacn      :integer,\ ; OUTPUT
                                 sncn    :float,  incn       :integer,\ ; OUTPUT
                                 sncan   :float,  incan      :integer,\ ; OUTPUT
                                 sncacn  :float,  incacn     :integer,\ ; OUTPUT
                                 sncacan :float,  incacan    :integer,\ ; OUTPUT
                                 tssdim  :integer,fnttype    :float)    ; OUTPUT

begin

;  READ CALIPSO FILELIST
   filename= asciiread(dir+filelist, -1, str)
   nfiles  = dimsizes(filename)

;  INITIALIZE THE TOTAL # OF EACH TYPE
   tssdim  = 0
   nttype0 = 0 ; NA
   nttype1 = 0 ; NA-AEROSOL-NA
   nttype2 = 0 ; NA-AEROSOL-CLOUD-NA
   nttype3 = 0 ; NA-CLOUD-NA
   nttype4 = 0 ; NA-CLOUD-AEROSOL-NA
   nttype5 = 0 ; NA-CLOUD-AEROSOL-CLOUD-NA
   nttype6 = 0 ; NA-CLOUD-AEROSOL-CLOUD-AEROSOL-NA

;  CALIPSO DATA LOOP
   do i = 0, nfiles-1
    data  = addfile(dir + filename(i), "r")
    lat   = data->Latitude
    lon   = data->Longitude
    eco   = data->Extinction_Coefficient_532
    ec    = eco*0.06
    qc    = data->Extinction_QC_Flag_532
    sfc   = data->Surface_Elevation_Statistics
    clf   = data->Cloud_Layer_Fraction
    ndim  = dimsizes(lat)
    npixel= ndim(0)
    time  = str_get_cols(filename(i), 31, 40) + " " + \
            str_get_cols(filename(i), 42, 49)
    date  = str_get_cols(filename(i), 31, 40)
    hour  = str_get_cols(filename(i), 42, 43)
    print("WORKING ON : " + time)
    system("date")

;  DEFINE DAYTIME OR NIGHTTIME FOR CALIPSO
    d_or_n  = str_get_cols(filename(i), 51, 51)
    if(d_or_n .eq. "D")then
     dntime= " Daytime "
    else
     dntime= " Nighttime "
    end if
;  QUALIFY THE QUALITY OF EXTINCTION COEFFICIENT
    qc2   = qc(:,:,0)
    oneqc2= ndtooned(qc2)
    nqc2  = dimsizes(qc2)
    qc2ind= ind_resolve(ind(oneqc2 .ne. 0.0 .and. oneqc2 .ne. 1.0 .and. \
                            oneqc2 .ne. 2.0 .and. oneqc2 .ne. 16.), nqc2)
    dimqc2= dimsizes(qc2ind)
    qcnpts = dimqc2(0)
    ndimqc = dimqc2(1)
    do j = 0, qcnpts-1
     ec(qc2ind(j, 0), qc2ind(j, 1)) = bv1
    end do
    delete(oneqc2)
    delete(qc2ind)


; SET ALL THE NEGATIVE VALUE TO bv2
   do j = 0, ndim(0)-1
    do k = 0, ndim(1)-1
     if(ec(j,k) .lt. 0.0 .or. \
        ec(j,k) .eq. bv2)then
      ec(j,k) = bv1
     end if
    end do
   end do

;  SELECT THE CALIPSO DATA WHICH ARE IN THE FIRE REGION
    slat   = new((/npixel/), float, bv1)
    slon   = new((/npixel/), float, bv1)
    sec    = new((/npixel, n_layer/), float, bv1)
    ssfc   = new((/npixel/), float, bv1)
    sclf   = new((/npixel, n_layer/), float, bv1)
    slat   = lat(:,1)
    slon   = lon(:,1)
    sec    = ec (:,:)
    ssfc   = sfc(:,2)
    sclf   = clf(:,:)
    index  = ind(slat .gt. minlat .and. slat .lt. maxlat .and. \
                 slon .gt. minlon .and. slon .lt. maxlon)
    if (dimsizes(index) .gt. 1 .and. .not.all(ismissing(index))) then
     sslat  = slat(index)
     sslon  = slon(index)
     ssec   = sec (index,:)
     sssfc  = ssfc(index)
     ssclf  = sclf(index,:)
     ssdim  = dimsizes(sslat)
     print("SELECTED PIXEL # : " + ssdim(0))

;  GET ALL THE DATA TO THE ABOVE GROUND LEVEL FOR CALIPSO
     sssec  = new((/ssdim(0), n_layer/), float, bv1)
     sssclf = new((/ssdim(0), n_layer/), float, bv1)
     do j = 0, ssdim(0)-1
      aglindex1   = ind(oheight .ge. sssfc(j))
      naglindex1  = aglindex1(0)
      if(naglindex1 .gt. 1)then
       sssec(j, (n_layer-1):naglindex1) = \
       ssec(j, (n_layer-naglindex1-1):0)
       sssclf(j, (n_layer-1):naglindex1) = \
       ssclf(j, (n_layer-naglindex1-1):0)
      end if
      delete(aglindex1)
      delete(naglindex1)
     end do 


;  DIVIDE OLD LAYER(340) INTO NEW LAYER FOR CALIPSO
     nl      = stride
     ssssec  = new((/ssdim(0), n_old_layer/), float, bv1)
     ssssclf = new((/ssdim(0), n_old_layer/), float, bv1)
     ssssec  = sssec(:,(n_layer-9):(n_layer-n_old_layer-8))
     ssssclf = sssclf(:,(n_layer-9):(n_layer-n_old_layer-8))
     sssssec = new((/ssdim(0), n_new_layer/), float, bv1)
     sssssclf= new((/ssdim(0), n_new_layer/), float, bv1)
     do j = 0, n_new_layer-2
      sssssec(:, j) = dim_sum_n(ssssec(:, nl:(nl+stride-1)), 1)
      sssssclf(:, j)= dim_sum_n(ssssclf(:, nl:(nl+stride-1)), 1)
      nl            = nl + stride
     end do

     isec   = new((/ssdim(0), n_new_layer/), integer, bv3)
     isclf  = new((/ssdim(0), n_new_layer/), integer, bv3)
     isclfec= new((/ssdim(0), n_new_layer/), integer, bv3)
     do j = 0, ssdim(0)-1
      do k = 0, n_new_layer-1
       if (.not.ismissing(sssssec(j,k)) .and. \
           sssssec(j,k) .gt. 0.0) then
        isec(j,k)    = 1
        isclfec(j,k) = 1
       end if
       if (.not.ismissing(sssssclf(j,k)) .and. \
           sssssclf(j,k) .gt. 0.0 .and. \
           ismissing(isec(j,k))) then
        isclf(j,k)   = 2
        isclfec(j,k) = 2
       end if
      end do ; END OF J LOOP
     end do ; END OF K LOOP

;  COUNT THE NUMBER OF DIFFERENT CONDITIONS
     ntype0 = 0 ; NA
     ntype1 = 0 ; NA-AEROSOL-NA
     ntype2 = 0 ; NA-AEROSOL-CLOUD-NA
     ntype3 = 0 ; NA-CLOUD-NA
     ntype4 = 0 ; NA-CLOUD-AEROSOL-NA
     ntype5 = 0 ; NA-CLOUD-AEROSOL-CLOUD-NA
     ntype6 = 0 ; NA-CLOUD-AEROSOL-CLOUD-AEROSOL-NA

     do j = 0, ssdim(0)-1
      type0 = 0
      type1 = 0
      type2 = 0
      type3 = 0
      type4 = 0
      type5 = 0
      type6 = 0
      do k = n_new_layer-1, 0, 1

;  JUDGE TYPE0
       if (ismissing(isclfec(j,k))) then
        type0 = 1
       end if
;  JUDGE TYPE1
       if (.not.ismissing(isclfec(j,k)) .and. isclfec(j,k) .eq. 1 .and. type3 .eq. 0) then
        type1 = 1
       end if
;  JUDGE TYPE2
       if (.not.ismissing(isclfec(j,k)) .and. isclfec(j,k) .eq. 2 .and. type1 .eq. 1) then
        type2 = 1
       end if
;  JUDGE TYPE3
       if (.not.ismissing(isclfec(j,k)) .and. isclfec(j,k) .eq. 2 .and. type1 .eq. 0) then
        type3 = 1
       end if
;  JUDGE TYPE4
       if (.not.ismissing(isclfec(j,k)) .and. isclfec(j,k) .eq. 1 .and. type3 .eq. 1) then
        type4 = 1
       end if
;  JUDGE TYPE5
       if (.not.ismissing(isclfec(j,k)) .and. isclfec(j,k) .eq. 2 .and. type4 .eq. 1) then
        type5 = 1
       end if
;  JUDGE TYPE6
       if (.not.ismissing(isclfec(j,k)) .and. isclfec(j,k) .eq. 1 .and. type5 .eq. 1) then
        type6 = 1
       end if
      end do
;  COUNT THE NUMBER OF TYPE1
      if (type1 .eq. 1 .and. type2 .eq. 0 .and. type3 .eq. 0) then
       snan(ntype1, :) = sssssec(j, :)
       inan(ntype1, :) = isclfec(j, :)
       ntype1 = ntype1 + 1
      end if
;  COUNT THE NUMBER OF TYPE2
      if (type1 .eq. 1 .and. type2 .eq. 1 .and. type3 .eq. 0) then
       snacn(ntype2, :) = sssssec(j, :)
       inacn(ntype2, :) = isclfec(j, :)
       ntype2 = ntype2 + 1
      end if
;  COUNT THE NUMBER OF TYPE3
      if (type3 .eq. 1 .and. type4 .eq. 0 .and. type0 .eq. 0 .and. type1 .eq. 0) then
       sncn(ntype3, :) = sssssec(j, :)
       incn(ntype3, :) = isclfec(j, :)
       ntype3 = ntype3 + 1
      end if
;  COUNT THE NUMBER OF TYPE4
      if (type3 .eq. 1 .and. type4 .eq. 1 .and. type5 .eq. 0 .and. type1 .eq. 0) then
       sncan(ntype4, :) = sssssec(j, :)
       incan(ntype4, :) = isclfec(j, :)
       ntype4 = ntype4 + 1
      end if
;  COUNT THE NUMBER OF TYPE5
      if (type4 .eq. 1 .and. type5 .eq. 1 .and. type6 .eq. 0 .and. type1 .eq. 0) then
       sncacn(ntype5, :) = sssssec(j, :)
       incacn(ntype5, :) = isclfec(j, :)
       ntype5 = ntype5 + 1
      end if
;  COUNT THE NUMBER OF TYPE6
      if (type5 .eq. 1 .and. type6 .eq. 1 .and. type0 .eq. 0 .and. type1 .eq. 0) then
       sncacan(ntype6, :) = ssec(j, :)
       incacan(ntype6, :) = isclfec(j, :)
       ntype6 = ntype6 + 1
      end if
      if (type1 .eq. 0 .and.\
          type2 .eq. 0 .and.\
          type3 .eq. 0 .and.\
          type4 .eq. 0 .and.\
          type5 .eq. 0 .and.\
          type6 .eq. 0 ) then
       ntype0 = ntype0 + 1
      end if
     end do
     tssdim  = tssdim  + ssdim(0)
     nttype0 = nttype0 + ntype0
     nttype1 = nttype1 + ntype1
     nttype2 = nttype2 + ntype2
     nttype3 = nttype3 + ntype3
     nttype4 = nttype4 + ntype4
     nttype5 = nttype5 + ntype5
     nttype6 = nttype6 + ntype6
print("N     : " + ntype0)
print("NAN   : " + ntype1)
print("NACN  : " + ntype2)
print("NCN   : " + ntype3)
print("NCAN  : " + ntype4)
print("NCACN : " + ntype5)
print("NCACAN: " + ntype6)
     delete(sslat)
     delete(sslon)
     delete(ssec)
     delete(ssclf)
     delete(sssec)
     delete(sssfc)
     delete(sssclf)
     delete(ssssec)
     delete(ssssclf)
     delete(sssssec)
     delete(sssssclf)
     delete(isec)
     delete(isclf)
     delete(isclfec)
    end if
    delete(index)
    delete(lat)
    delete(lon)
    delete(ec)
    delete(eco)
    delete(sfc)
    delete(qc)
    delete(qc2)
    delete(clf)
    delete(slat)
    delete(slon)
    delete(sec)
    delete(ssfc)
    delete(sclf)
   end do ; END OF I LOOP
   tnttype  = nttype0+nttype1+nttype2+nttype3+nttype4+nttype5+nttype6
   if (tssdim .ne. 0)then
    fnttype0 = nttype0/int2flt(tssdim)
    fnttype1 = nttype1/int2flt(tssdim)
    fnttype2 = nttype2/int2flt(tssdim)
    fnttype3 = nttype3/int2flt(tssdim)
    fnttype4 = nttype4/int2flt(tssdim)
    fnttype5 = nttype5/int2flt(tssdim)
    fnttype6 = nttype6/int2flt(tssdim)
    fnttype  = (/fnttype0,fnttype1,fnttype2,fnttype3,fnttype4,fnttype5,fnttype6/)*100
    xlabel   = (/"N     ", "NAN   ", "NACN  ", "NCN   ", "NCAN  ", "NCACN ", "NCACAN"/)
    print("TOTAL " + xlabel + " : " + fnttype)
   end if
return
end
