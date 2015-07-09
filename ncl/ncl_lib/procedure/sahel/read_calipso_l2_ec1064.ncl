; $ID: read_calipso_l2_ec1064.ncl V01 02/07/2012 23:29 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_calipso_l2_ec1064 READ CALIPSO LEVEL 2 DATA 
;  (CAL_LID_L2_05kmAPro-Prov-V3-01), INCLUDING PARTICULATE DEPOLARIZATION RATIO, 
;  QUALITY FLAG, CLOUD LAYER FRACTION, SURFACE ELEVATION STATISTICS, LATITUDE, 
;  LONGITUDE AND SO ON.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dirh    (string) : DIRECTORY OF CALIPSO LEVEL 2 DATA              [---]
;  (2 ) filename(string) : ONE FILE NAME OF CALIPSO LEVEL 2 DATA          [---]
;  (3 ) bv1     (float)  : MISSING VALUE FOR FLOAT                        [---]
;  (4 ) minlat  (float)  : MINIMUM LATITUDE OF LIMITED REGION             [deg]
;  (5 ) maxlat  (float)  : MAXIMUM LATITUDE OF LIMITED REGION             [deg]
;  (6 ) minlon  (float)  : MINIMUM LONGITUDE OF LIMITED REGION            [deg]
;  (7 ) maxlon  (float)  : MAXIMUM LONGITUDE OF LIMITED REGION            [deg]
;  (8 ) dateh   (string) : CALIPSO DATE (FORMAT : YEAR-MONTH-DAY, 
;                          i.e. 2008-02-26)                               [---]
;  (9 ) timeh   (string) : CALIPSO TIME (FORMAT : TIME, 01)               [---]
;  (10) lathh   (float)  : CALIPSO LATITUDE FOR SELECTED GROUND TRACK BASED 
;                          ON THE LIMITED REGION                          [deg]
;  (11) lonhh   (float)  : CALIPSO LONGITUDE FOR SELECTED GROUND TRACK BASED
;                          ON THE LIMITED REGION                          [deg]
;  (12) ech    (float)  : CALIPSO PARTICULATE DEPOLARIZATION RATIO       [   ]
;  (13) clfh1   (float)  : CALIPSO CLOUD FRACTION                         [---]
;  (14) aodh    (float)  : CALIPSO AOD FOR TOTAL COLUMN                   [---]
;  (15) sfch1   (float)  : CALIPSO SURFACE ELEVATION STATISTICS           [---]
;  (16) d_or_n  (string) : CALIPSO DAYTIME OR NIGHTTIME                   [---]
;  (17) indexh  (integer): SELECTED CALIPSO DATA INDEX IN LIMITED REGION  [---]
;  (18) ndimh   (integer): # OF SELECTED CALIPSO DATA INDEX IN LIMITED 
;                          REGION                                         [---]
;  (19) timeall (string) : CALIPSO TIME STRING (FORMAT : HOUR-MINUTE-SECOND,
;                          i.e. 01-01-01)                                 [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/07/2012)
;******************************************************************************

undef("read_calipso_l2_ec1064")
procedure read_calipso_l2_ec1064 \
                         (dirh      :string, filename  :string, \ ; INPUT
                          bv1       :float,  minlatn   :float,  \ ; INPUT
                          maxlatn   :float,  minlonn   :float,  \ ; INPUT
                          maxlonn   :float,                     \ ; INPUT
                          dateh     :string, timeh     :string, \ ; OUTPUT
                          lathh     :float,  lonhh     :float,  \ ; OUTPUT
                          ech      :float,  clfh1     :float,  \ ; OUTPUT
                          aodh      :float,  sfch1     :float,  \ ; OUTPUT
                          d_or_n    :string, indexh    :integer,\ ; OUTPUT
                          ndimh     :integer,timeall   :string)   ; OUTPUT

begin

;  READ CALIPSO LEVEL2 DATA
   print("START TIME : ")
   system("date")
   fh     = addfile(dirh+filename, "r")
   d_or_n = str_get_cols(filename, 51, 51)
   ech    = fh->Extinction_Coefficient_1064
   clfh   = fh->Cloud_Layer_Fraction
   aodh   = fh->Column_Optical_Depth_Aerosols_1064
   sfch   = fh->Surface_Elevation_Statistics
   qch    = fh->Extinction_QC_Flag_1064
   lath   = fh->Latitude
   lonh   = fh->Longitude
   dimech= dimsizes(ech)
   npixel = dimech(0)
   nlevelh= dimech(1)
   dateh  = str_get_cols(filename, 31, 40)
   timeh  = str_get_cols(filename, 42, 43)
   timeall= str_get_cols(filename, 42, 49)
   clfh1  = new((/npixel, nlevelh/), float, bv1)
   sfch1  = new(npixel, float, bv1)
   clfh1  = clfh
   sfch1  = sfch(:,2)

;  QUALIFY THE QUALITY OF EXTINCTION COEFFICIENT
   qch2   = qch(:,:,0)
   oneqch2= ndtooned(qch2)
   nqch2  = dimsizes(qch2)
   qch2ind= ind_resolve(ind(oneqch2 .ne. 0.0 .and. oneqch2 .ne. 1.0 .and.\
                            oneqch2 .ne. 2.0 .and. oneqch2 .ne. 16.), nqch2)
   dimqch2= dimsizes(qch2ind)
   qcnpts = dimqch2(0)
   ndimqc = dimqch2(1)
   do j = 0, qcnpts-1
    ech(qch2ind(j, 0), qch2ind(j, 1)) = bv1
   end do
   delete([/qch2, oneqch2, qch2ind/])

;  ASSIGN ARRAY TO A NEW VALUE
   do j = 0, nlevelh-1
    do k = 0, npixel-1
     if(clfh1(k,j) .le. 0.0)then
      clfh1(k,j) = bv1
     else
      clfh1(k,j) = 0.0-clfh1(k,j)
     end if
    end do
   end do
;  ASSIGN NEW 1 DIMENSIONAL ARRAY FOR LATITUDE AND LONGITUDE OF CALIPSO
   lathh = lath(:,1)
   lonhh = lonh(:,1)

;  SELECTED REGION FROM CALIPSO BASED ON LIMITED REGION
   indexha= ind(lathh .ge. minlatn .and. lathh .le. maxlatn .and. \
                lonhh .ge. minlonn .and. lonhh .le. maxlonn)
   ndimh  = dimsizes(indexha)
   indexh(0: (ndimh-1)) = indexha

return
end
