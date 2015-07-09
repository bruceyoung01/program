 function read_veg, TYPE5=TYPE5

;This is fort.16 in my subdirectory   rmy/EMIS


;It has dimension IVEG(360,180)
;and is read into a fortran program with the following statement:


;      READ(16,*)IVEG

 IVEG   = fltarr(360,180)
 IVEG9  = IVEG
 GLBCRP = IVEG
 IVEG5  = IVEG

 Openr, il, '~rjp/IDL/data/surface_type.txt', /get
   readf, il, IVEG
 free_lun, il

 Openr, il, '~rjp/IDL/data/croplands.txt', /get
   readf, il, GLBCRP
 free_lun, il

 ; General model and grid information
 Modelinfo = CTM_TYPE('generic', RES=1)
 Gridinfo  = CTM_GRID(Modelinfo)

 
;then is immediately processed via the following code (Matthews
;uses '32' types of vegetation and Jennifer found that this was far
;too cumbersome for our needs)


;So she created a new vegetation matrix called IVEG9(360,180) which
;contains 10 different categories (one of them being water)

;**** Put landuse types into catagories:
;       0-water; 1-rainforest; 2-forest; 3-woodland; 4-shrubs/thicket
;       5-tundra; 6-Grass w.10-40% trees: 7-Grassland; 8-Agriculture
;       9-Desert+Ice

;     PUT LANDUSE TYPES INTO 5 DIFFERENT CATETORIES
;       0-water or Desert+Ice
;       1-tropical forest
;       2-extra tropical forest
;       3-Boreal forest
;       4-Grasslands and Shirubs
;       5-Agriculture

      For J=0,gridinfo.jmx-1L do begin
      For I=0,gridinfo.imx-1L do begin
        IF(IVEG(I,J) EQ 32)                     THEN IVEG9(I,J)=8
        IF(IVEG(I,J) EQ 30 OR IVEG(I,J) EQ 31)  THEN IVEG9(I,J)=9
        IF(IVEG(I,J) EQ 22 OR IVEG(I,J) EQ 29)  THEN IVEG9(I,J)=5
        IF(IVEG(I,J) GE 24 AND IVEG(I,J) LE 28) THEN IVEG9(I,J)=7
        IF(IVEG(I,J) EQ 23)                     THEN IVEG9(I,J)=6
        IF(IVEG(I,J) LE 21)                     THEN IVEG9(I,J)=4
        IF(IVEG(I,J) LE 16)                     THEN IVEG9(I,J)=3
        IF(IVEG(I,J) LE 11)                     THEN IVEG9(I,J)=2
        IF(IVEG(I,J) LE  4)                     THEN IVEG9(I,J)=1
        IF(IVEG(I,J) EQ  0)                     THEN IVEG9(I,J)=0

        IVEG5[I,J] = IVEG9[I,J]
        IF(IVEG9[I,J] EQ 9) THEN IVEG5[I,J] = 0

        IF(IVEG9[I,J] EQ 4 OR IVEG9[I,J] EQ 5 OR $
           IVEG9[I,J] EQ 6 OR IVEG9[I,J] EQ 7) THEN IVEG5[I,J] = 4

        IF(IVEG9[I,J] EQ 8) THEN IVEG5[I,J] = 5

        IF(IVEG9[I,J] EQ 2 OR IVEG9[I,J] EQ 3) THEN BEGIN
           IVEG5[I,J] = 2
           IF (GRIDINFO.YMID[J] LT 30.) THEN IVEG5[I,J] = 1

         ;Boreal forests (Write over the northern extratropical forest data)
         ; Canada
           IF (GRIDINFO.YMID[J] GE 43.   AND GRIDINFO.YMID[J] LE 70. AND $
               GRIDINFO.XMID[I] GE -154. AND GRIDINFO.XMID[I] LE -61. ) THEN $
               IVEG5[I,J] = 3
         ; Russia
           IF (GRIDINFO.YMID[J] GE 43. AND GRIDINFO.YMID[J] LE 70. AND $
               GRIDINFO.XMID[I] GE 65. AND GRIDINFO.XMID[I] LE 160. ) THEN $
               IVEG5[I,J] = 3
         ENDIF

      ENDFOR
      ENDFOR


; MULTIPANEL, ROW=2, COL=1
; tvmap, IVEG,  /cbar, divis=4, /coast, /countries
; TVMAP, IVEG9, /CBAR, DIVIS=10, /COAST, /COUNTRIES, /SAMPLE

 IF KEYWORD_SET(TYPE5) THEN RETURN, IVEG5 ELSE return, IVEG9

 end
