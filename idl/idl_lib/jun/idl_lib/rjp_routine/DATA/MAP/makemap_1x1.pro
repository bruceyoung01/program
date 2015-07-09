
function define_map

; EU15 countries and western Europe
; Austria, Belgium, Denmark, Finland, France, 
; WGermany, Greece, Iceland, Ireland, Italy,
; Luxembourg, Netherlands, Portugal, Spain, Sweden, 
; Norway, Switzerland, U.K.
; Country codes

 EUW = [10L, 15L, 42L, 54L, 55L, $
        61L, 64L, 76L, 81L, 83L, $
       100L,119L,136L,155L,160L, $
       126L,161L,175L]

; Eastern Europe (Albania, Bosnia, Bulgaria, Croatia, Czech Republic, 
; Estonia, Hungary, Latvia, Lithuania, FYR Macedonia, Poland, Romania, 
; Slovakia, Slovenia, Serbia and Montenegro, YUGOSLAVI 
 EUE = [2L, 24L, 41L, 60L, 75L, $
      135L,139L,188L]

 EUROPE = [EUW, EUE]

;Africa (Algeria, Angola, Benin, Botswana, Burkina Faso, Burundi, Cameroon,
; Cape Verde, Central African Republic, Chad, Comoros, Congo, 
; Democratic Republic of the Congo (Zaire), Cote dlvoire(IVORYCST), Djibouti, Egypt, 
; Equatorial Guinea, Eritrea, Ethiopia, Gabon, Gambia, Ghana, Guinea, 
; Guinea-Bissau, Kenya, Lesotho, Liberia, Libya, Madagascar, Malawi, Mali,
; Mauritania, Mauritius, Morocco, Mozambique, Namibia, Niger, Nigeria, 
; Rwanda, Sao Tome and Principe, Senegal, Seychelles, Sierraleone, Somalia,
; South Africa, Sudan, Swaziland, Tanzania, Togo, Tunisia, Uganda, Zambia, 
; Zimbabwe)
Af = [3L, 5L, 17L, 21L, 177L, 26L, 27L, $
      29L, 30L, 31L, 35L, 36L, $
      189L, 84L, 43L, 47L, $
      49L,    50L, 58L, 59L, 62L, 69L, $
      70L, 89L, 96L, 97L, 98L, 102L, 103L, $
     106L, 109L, 110L, 114L, 115L, 116L, 124L, 125L, 140L, 145L, 147L, $
     148L, 149L, 152L, 153L, 157L, 159L, 164L, 166L, 169L, 173L, 183L, 190L]

; South America (Argentina, Bolivia, Brazil, Chile, Colombia, 
; Ecuador, Guyana, Paraguay, Peru, Suriname, uruguay, Venezuela)
 SA = [8L, 20L, 22L, 32L, 34L, 46L, 71L, 132L, 133L, 158L, 178L, 181L]

; Central America
; Regions = [MEXICO, GUATEMALA, NICARAGUA, $
;            COSTARICA, ELSALVADR, BELIZE, $
;            HONDURAS, PANAMA]
 CA = [111L, 68L, 123L, 38L, 48L, 16L, 73L, 130L]

; Oceania (Australia, Fiji, Grand Terre, Guam, New Caledonia, 
; Northern Marianas, Saipan, Society Islands, Tahiti, Tonga, Vanuatu
 Oce = [9L, 53L, 129L, 121L, 122L, 167L, 179L]

; Former USSR
 USSR = 154L

; China
 China = 33L

; Rest of Asia (Afghanista, Bahrain, Bangladesh, Bhutan, Brunei, Cambodia, 
; Cyprus, East Timor, India, Indonesia, Iran, Iraq, Israel, Japan, Jordan, 
; Kazakhastan, Kuwait, Kyrgyzstan, Laos, Lebanon, Malaysia, Maldives, 
; Mongolia, Myanmar, Nepal, North Korea, Oman, Pakistan, Philippines, 
; Qatar, Saudi Arabia, Singapore, South Korea, Sri Lanka, Syria, Taiwan, 
; Tajikistan, Thailand, Turkey, Turkmenistan, united Arab Emirates,
; Uzbekistan, Vietnam, Yemen, Turkey)
Asia = [1L, 12L, 13L, 19L, 23L, $
       40L, 77L, 78L, 79L, 80L, 82L, 86L, 87L, $
       91L, 92L, 93L, 94L, 95L, 104L, 105L, $
       113L, 118L, 127L, 128L, 134L, 137L, 146L, $
       150L, 156L, 162L, 163L, 165L, 174L, 182L, 186L, 187L, 170L]

; rmy Read in the 1x1 GISS codes describing to which country each
; rmy 1x1 is assigned.
; For example, USA = 176, Canada = 28

; generic 1x1 emission grid.

 Grid = CTM_Grid(CTM_TYPE('generic', res=1))

 USA       = 176L
 CANADA    = 28L
 MEXICO    = 111L
 GUATEMALA = 68L
 NICARAGUA = 123L
 COSTARICA = 38L
 ELSALVADR = 48L
 BELIZE    = 16L
 HONDURAS  = 73L
 PANAMA    = 130L
 CHINA     = 33L
 KOREAS    = 92L
 KOREAN    = 91L
 INDIA     = 77L
 JAPAN     = 86L
 BRUNEI    = 23L 
 BURMA     = 25L
 CAMBODIA  = 88L
 INDONESIA = 78L            
 LAOS      = 94L
 MALAYSIA  = 104L
 PHILIPPINES = 134L
 SINGAPORE = 150L
 THAILAND  = 165L
 VIETNAM   = 182L
 HONGKONG  = 74L
 TAIWAN    = 163L
 MONGOLIA  = 113L
 PAKISTAN  = 128L

; North America
  NorthAmerica = [USA,CANADA,MEXICO]  ; North America

; Central America
; Regions = [MEXICO, GUATEMALA, NICARAGUA, $
;            COSTARICA, ELSALVADR, BELIZE, $
;            HONDURAS, PANAMA]

; KOREA+JAPAN
;  REGIONS = [KOREAN,KOREAS,JAPAN]

; south-east asia
  SEASIA = [Brunei, Burma, Cambodia, Indonesia, $
            Laos, Malaysia, Philippines, Singapore, $
            Thailand, Vietnam]

; east asia
  EASIA = [CHINA,JAPAN,KOREAN,KOREAS,HONGKONG,TAIWAN,MONGOLIA]

; ASIA
  ASIA = [EASIA,SEASIA,INDIA]


; DEfine region

;  REGIONS = [USA, CANADA]
;  REGIONS = CANADA
  REGIONS = USA

  ctncode = lonarr(360,180)
  Openr,il,'newcountry.codes.1x1.Jun15',/Get
  Readf,il,ctncode
  Free_lun,il

  map = fltarr(360,180) ; generic 1x1 emission grid.

  for j = 0, 179 do begin
  for i = 0, 359 do begin
      chk = where((ctncode[i,j]/100) eq Regions)
      if ( chk[0] ne -1 ) then map[i,j] = 1.

;      if Grid.xmid[i] lt -130. then map[i,j] = 0.
  endfor
  endfor

  tvmap, map, /conti, /sample

  return, map

 end

;==========================================================================

 function intermap, oldmap, res=res, thold=thold

   if n_elements(oldmap) eq 0 then return, -1
   if n_elements(res)    eq 0 then return, -1
   if n_elements(thold)  eq 0 then thold = 0.5

   ; oldmap is hardwired on 1x1 generic grid
   InType = CTM_Type( 'generic', Resolution=1 )
   InGrid = CTM_Grid( InType, /No_vertical )

   ; MODELINFO, GRIDINFO structures, and surface areas for new grid

   OutType = CTM_Type( 'GEOS3', Resolution=res )
   OutGrid = CTM_Grid( OutType, /No_vertical )

;   Newmap = CTM_Regrid( oldmap, InGrid, OutGrid, /No_normalize )

   Newmap = CTM_Regridh( Oldmap, InGrid, OutGrid, /PER_UNIT_AREA, $
                          Use_Saved_Weights=Use_Saved_Weights )
   map = Newmap

   For J = 0, outgrid.jmx-1 do begin
   For I = 0, outgrid.imx-1 do begin
     If map[i,j] gt thold then Newmap[i,j] = 1. else Newmap[i,j] = 0.
   Endfor
   Endfor

   multipanel, row=2, col=1
   tvmap, oldmap, /sample, /conti, /cbar
   tvmap, newmap, /sample, /conti, /cbar

   return, newmap

 End

;=======================================================================

  res = 1

  if N_elements(code)    eq 0 then      code    = define_map()
  map_1x1_05 = code
;  if N_elements(map_1x1_05) eq 0 then  map_1x1_05 = intermap(code, res=res, thold=0.5)
;  if N_elements(map_1x1_03) eq 0 then  map_1x1_03 = intermap(code, res=1, thold=0.3)
;  if N_elements(map_1x1_01) eq 0 then  map_1x1_01 = intermap(code, res=1, thold=0.1)

     multipanel, row=2, col=1
;     plot_region, map_1x1_05, /sample
;     plot_region, map_1x1_03, /sample
;     plot_region, map_1x1_01, /sample

     idmap = map_1x1_05

;     plot_region, code, /sample      
;     plot_region, idmap, /sample
      modelinfo = ctm_type('generic',res=res)
      gridinfo  = ctm_grid(modelinfo)
      iy = where(gridinfo.ymid lt 46.)

     click_map, gridinfo, limit=[10.,-170.,80.,-60.],idmap=idmap,/countries

;  openw, il, 'EUROPE.map_1x1.bin', /f77, /get
;  writeu, il, map_1x1
;  free_lun, il

stop

  write_bpch, idmap, filename='./mask/alaska_mask.generic.1x1', $
      ngas=2L, unit='unitless', $
      category='LANDMAP', tau0=nymd2tau(19850101L), $
      tau1=nymd2tau(19850101L), append=append


End
