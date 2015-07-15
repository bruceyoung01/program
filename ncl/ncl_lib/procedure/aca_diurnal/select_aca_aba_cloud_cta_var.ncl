;  $ID: select_aca_aba_cloud_cta_var.ncl V01 06/23/2015 23:30 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_aca_aba_cloud_cta_var.ncl SELECTS THE AEROSOL BASE ALTITUDE 
;  FROM ALL AVAILABLE 8 LAYERS AEROSOL, AND CLOUD TOP ALTITUDE FROM ALL AVAILABLE 
;  10 LAYERS CLOUD.
;  NOTICE :
;  Layer_Base_Altitude(3728, 8), FOR THE 2ND DIMENSION IS NUMER OF AVAILABLE 
;  AEROSOL LAYERS. 0 IS THE HIGHEST LAYER, AND 7 IS THE LOWEST LAYER. IN 
;  ORDER TO SELECT Layer_Base_Altitude, WE SHOULD SELECT ALL THE LOWEST ALTITUDE 
;  FROM THE LOWEST LAYER TO THE HIGHEST LAYER.
;  Layer_Top_Altitude(3728, 10), FOR THE 2ND DIMENSION IS NUMER OF AVAILABLE 
;  CLOUD LAYERS. 0 IS THE HIGHEST LAYER, AND 9 IS THE LOWEST LAYER. IN 
;  ORDER TO SELECT Layer_Top_Altitude, WE SHOULD SELECT ALL THE HIGHEST ALTITUDE 
;  FROM THE HIGHEST LAYER TO THE LOWEST LAYER.
;
;  RESTRICTIONS FOR SELECTING MONO-LAYER AEROSOL AND CLOUD FIELDS FROM 
;  Costantino_2013, WHICH IS
;  (1 ) Costantino, L. and Bréon, F.-M.: Aerosol indirect effect on warm clouds 
;       over South-East Atlantic, from co-located MODIS and CALIPSO observations, 
;       Atmos. Chem. Phys., 13, 69-88, doi:10.5194/acp-13-69-2013, 2013.
;  RESTRICTIONS (Page 73-74: 2.3 MODIS-CALIPSO coincidence):
;  ============================================================================
;  (1 ) Number_Layers_Found = 1
;       REASON : AVOID MULTI-LAYERS EFFECTS, RETRIEVALS CAN BE AMBIGUOUS.
;  (2 ) CLOUD TOP PRESSURE CTP>600hPa
;       REASON : ONLY CONSIDER SHALLOW CLOUDS
;  (3 ) 5<COT<35 (COT IS FROM MODIS)
;       REASON : NEITHER A CLEAR DISTINCTION BETWEEN AEROSOL AND CLOUDS, NOR AN 
;                ACCURATE RETRIEVAL OF CLOUD PROPERTIES IS RELIABLY POSSIBLE 
;                FOR OPTICALLY THIN CLOUDS(Nakajima, 2001).
;       Nakajima, T., Higurashi, A., Kawamoto, K., and Penner, J. E.:
;       A possible of correlation between satellite-derived cloud and
;       aerosol microphysical parameters, Geophys. Res. Lett., 28,
;       1171–1174, 2001.
;  (4 ) AEROSOL TOP LAYER ALTITUDE ATA<10km
;  (5 ) LIQUID WATER PATH LWP<300 g/m^2
;       REASON : AVOID DEEP CONVECTIVE CLOUDS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) Layer_Base_Altitude   (2-D):CALIOP L2 AEROSOL Layer_Base_Altitude [KM ]
;  (2 ) Layer_Top_Altitude    (2-D):CALIOP L2 CLOUD Layer_Top_Altitude    [KM ]
;  (3 ) acLayer_Base_Altitude (1-D):SELECTED Layer_Base_Altitude FOR ALL 
;                                   THE LAYERS                            [KM ]
;  (4 ) ccLayer_Top_Altitude  (1-D):SELECTED Layer_Top_Altitude FOR ALL 
;                                   THE LAYERS                            [KM ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/23/2015)
;******************************************************************************
undef(" select_aca_aba_cloud_cta_var")
procedure  select_aca_aba_cloud_cta_var \
           (aLayer_Top_Altitude    :float,   aLayer_Base_Altitude    :float,\;INPUT
            aLayer_Top_Pressure    :float,   aMidlayer_Pressure      :float,\;INPUT
            aLayer_Base_Pressure   :float,   aLayer_Top_Temperature  :float,\;INPUT
            aMidlayer_Temperature  :float,   aLayer_Base_Temperature :float,\;INPUT
            aNumber_Layers_Found   :integer,                                \;INPUT
            cLayer_Top_Altitude    :float,   cLayer_Base_Altitude    :float,\;INPUT
            cLayer_Top_Pressure    :float,   cMidlayer_Pressure      :float,\;INPUT
            cLayer_Base_Pressure   :float,   cLayer_Top_Temperature  :float,\;INPUT
            cMidlayer_Temperature  :float,   cLayer_Base_Temperature :float,\;INPUT
            cNumber_Layers_Found   :integer,                                \;INPUT
            acLayer_Top_Altitude   :float,   acLayer_Base_Altitude   :float,\;OUTPUT
            acLayer_Top_Pressure   :float,   acMidlayer_Pressure     :float,\;OUTPUT
            acLayer_Base_Pressure  :float,   acLayer_Top_Temperature :float,\;OUTPUT
            acMidlayer_Temperature :float,   acLayer_Base_Temperature:float,\;OUTPUT
            ccLayer_Top_Altitude   :float,   ccLayer_Base_Altitude   :float,\;OUTPUT
            ccLayer_Top_Pressure   :float,   ccMidlayer_Pressure     :float,\;OUTPUT
            ccLayer_Base_Pressure  :float,   ccLayer_Top_Temperature :float,\;OUTPUT
            ccMidlayer_Temperature :float,   ccLayer_Base_Temperature:float) ;OUTPUT
begin
;  GET THE DIMENSION FOR Layer_Base_Altitude, AND Layer_Top_Altitude
   dim_aba = dimsizes(aLayer_Base_Altitude)
   npts    = dim_aba(0)
   nalayer = dim_aba(1)
   dim_cta = dimsizes(cLayer_Top_Altitude)
   nclayer = dim_cta(1)

;  ASSIGN AEROSOL acLayer_Base_Altitude WITH LOWEST ALTITUDE IN ALL THE LAYERS
   do ialayer = 0, nalayer-1
      aindex = ind(ismissing(acLayer_Base_Altitude)                     .and. \
                   aNumber_Layers_Found(:, 0) .eq. 1                    .and. \
                   cNumber_Layers_Found(:, 0) .eq. 1                    .and. \
                   aLayer_Top_Altitude(:, nalayer-1-ialayer) .le. 10.0  .and. \
                   .not.all(ismissing(aLayer_Base_Altitude(:, nalayer-1-ialayer))))
      if (.not.all(ismissing(aindex))) then
         acLayer_Top_Altitude    (aindex) = aLayer_Top_Altitude    (aindex, nalayer-1-ialayer)
         acLayer_Base_Altitude   (aindex) = aLayer_Base_Altitude   (aindex, nalayer-1-ialayer)
         acLayer_Top_Pressure    (aindex) = aLayer_Top_Pressure    (aindex, nalayer-1-ialayer)
         acMidlayer_Pressure     (aindex) = aMidlayer_Pressure     (aindex, nalayer-1-ialayer)
         acLayer_Base_Pressure   (aindex) = aLayer_Base_Pressure   (aindex, nalayer-1-ialayer)
         acLayer_Top_Temperature (aindex) = aLayer_Top_Temperature (aindex, nalayer-1-ialayer)
         acMidlayer_Temperature  (aindex) = aMidlayer_Temperature  (aindex, nalayer-1-ialayer)
         acLayer_Base_Temperature(aindex) = aLayer_Base_Temperature(aindex, nalayer-1-ialayer)
      end if
      delete([aindex])
   end do

;  ASSIGN CLOUD ccLayer_TOP_Altitude WITH HIGHEST ALTITUDE IN ALL THE LAYERS
   do iclayer = 0, nclayer-1
      cindex = ind(ismissing(ccLayer_Top_Altitude)            .and. \
                   aNumber_Layers_Found(:, 0) .eq. 1          .and. \
                   cNumber_Layers_Found(:, 0) .eq. 1          .and. \
                   cLayer_Top_Pressure(:, iclayer) .ge. 600.0 .and. \
                   .not.all(ismissing(cLayer_Top_Altitude(:, iclayer))))
      if (.not.all(ismissing(cindex))) then
	 ccLayer_Top_Altitude    (cindex) = cLayer_Top_Altitude    (cindex, iclayer)
	 ccLayer_Base_Altitude   (cindex) = cLayer_Base_Altitude   (cindex, iclayer)
	 ccLayer_Top_Pressure    (cindex) = cLayer_Top_Pressure    (cindex, iclayer)
	 ccMidlayer_Pressure     (cindex) = cMidlayer_Pressure     (cindex, iclayer)
	 ccLayer_Base_Pressure   (cindex) = cLayer_Base_Pressure   (cindex, iclayer)
	 ccLayer_Top_Temperature (cindex) = cLayer_Top_Temperature (cindex, iclayer)
	 ccMidlayer_Temperature  (cindex) = cMidlayer_Temperature  (cindex, iclayer)
	 ccLayer_Base_Temperature(cindex) = cLayer_Base_Temperature(cindex, iclayer)
      end if
      delete([/cindex/])
   end do

return
end
