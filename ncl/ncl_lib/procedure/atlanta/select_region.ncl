;  $ID: select_region.ncl V01 01/28/2014 13:17 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_region SELECTS THE STUDY REGION FROM THE WHOLE REGION, 
;  GIVING MINLAT, MAXLAT, MINLON, AND MAXLON.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/18/2013)
;******************************************************************************
;
undef("select_region")
procedure select_region \
          (minlat    :float,   maxlat  :float,  \; INPUT
           minlon    :float,   maxlon  :float,  \; INPUT
           mlat      :float,   mlon    :float,  \; INPUT
           mrad_qf   :integer, mrad    :float,  \; INPUT
           msza      :float,   msaa    :float,  \; INPUT
           mmp       :float,   mlza    :float,  \; INPUT
           mlaa      :float,                    \; INPUT
           smlat     :float,   smlon   :float,  \; OUTPUT
           smrad_qf  :integer, smrad   :float,  \; OUTPUT
           smsza     :float,   smsaa   :float,  \; OUTPUT
           smmp      :float,   smlza   :float,  \; OUTPUT
           smlaa     :float)                     ; OUTPUT

begin

    index1 = region_ind(mlat, mlon, minlat, maxlat, minlon, maxlon)
    if (any(ismissing(index1))) then
       print("?????????????????????????????????")
       print("NO VIIRS DATA IN THE STUDY REGION")
       print("?????????????????????????????????")
    else
       index1(0) = index1(0) - 2
       index1(1) = index1(1) + 2
       index1(2) = index1(2) - 2
       index1(3) = index1(3) + 2
       nmlat = index1(1) - index1(0)
       nmlon = index1(3) - index1(2)
       print("nmlat = " + nmlat + \
            " nmlon = " + nmlon)
       smlat(0:nmlat, 0:nmlon)     = mlat(index1(0):index1(1), index1(3):index1(2))
       smlon(0:nmlat, 0:nmlon)     = mlon(index1(0):index1(1), index1(3):index1(2))
       smrad_qf(0:nmlat, 0:nmlon)  = mrad_qf(index1(0):index1(1), index1(3):index1(2))
       smrad(0:nmlat, 0:nmlon)     = (/mrad(index1(0):index1(1), index1(3):index1(2))/)
       smsza(0:nmlat, 0:nmlon)     = msza(index1(0):index1(1), index1(3):index1(2))
       smsaa(0:nmlat, 0:nmlon)     = msaa(index1(0):index1(1), index1(3):index1(2))
       smmp(0:nmlat, 0:nmlon)      = mmp(index1(0):index1(1), index1(3):index1(2))
       smlza(0:nmlat, 0:nmlon)     = mlza(index1(0):index1(1), index1(3):index1(2))
       smlaa(0:nmlat, 0:nmlon)     = mlaa(index1(0):index1(1), index1(3):index1(2))

;  ADD LAITUDE AND LONGITUDE ATTIBUTE TO VARIABLES
;printVarSummary(smrad_qf)
       smrad_qf@lat2d = smlat
       smrad_qf@lon2d = smlon
;printVarSummary(smlat)
;printVarSummary(smlon)
;printVarSummary(smrad)
       if (isatt(smrad, "lat2d")) then
          delete_VarAtts(smrad, "lat2d")
       end if
       if (isatt(smrad, "lon2d")) then
          delete_VarAtts(smrad, "lon2d")
       end if
       smrad!0        = "DIM_002"
       smrad!1        = "DIM_003"
;printVarSummary(smrad)
       smrad@lat2d    = smlat
       smrad@lon2d    = smlon
       smsza@lat2d    = smlat
       smsza@lon2d    = smlon
       smsaa@lat2d    = smlat
       smsaa@lon2d    = smlon
       smmp@lat2d     = smlat
       smmp@lon2d     = smlon
       smlza@lat2d    = smlat
       smlza@lon2d    = smlon
       smlaa@lat2d    = smlat
       smlaa@lon2d    = smlon
    end if
end
