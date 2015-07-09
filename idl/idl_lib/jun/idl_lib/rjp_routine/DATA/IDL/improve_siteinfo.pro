function improve_siteinfo

  head = ''
  site = ''
  name = ''
  Addr = ''
  City = ''
  State= ''
  Lon  = ''
  Lat  = ''
  Elev = ''
 openr,il,'/users/ctm/rjp/Data/IMPROVE/Raw_data/IMPROVELocTable.txt',/get
 for D = 0, 3 do readf, il, head

 while (not eof(il)) do begin
   readf, il, head
   bit   = byte(head)
   Site  = [Site,  strtrim(bit[0:4],2)    ]
   State = [State, strtrim(bit[10:11],2)  ]
   Elev  = [Elev,  strtrim(bit[17:21],2)  ]
   Lat   = [Lat,   strtrim(bit[32:38],2)  ]
   Lon   = [Lon,   strtrim(bit[47:55],2)  ]
   Name  = [Name,  strtrim(bit[92:134],2) ]

;   Addr  = [Addr,  strtrim(bit[261:*],2) ]
;   City  = [City,  strtrim(bit[176:214],2)]

 endwhile

   Site  = Site[1:*]
   Name  = Name[1:*]
;   Addr  = Addr[1:*]
;   City  = City[1:*]
   State = State[1:*]
   Lon   = Lon[1:*]
   Lat   = Lat[1:*]
   Elev  = Elev[1:*]

   for ic = 0, N_elements(Site)-1 do begin
     if (Site(ic) eq '') then Site(ic) = 'NaN'
     if (Name(ic) eq '') then Name(ic) = 'NaN'
     if (Lon(ic ) eq '') then Lon(ic ) = 'NaN'
     if (Lat(ic ) eq '') then Lat(ic ) = 'NaN'
     if (Elev(ic) eq '') then Elev(ic) = 'NaN'
   endfor

   Lon  = float(Lon) 
   Lat  = float(Lat)
   Elev = float(Elev)
   Statename = State
 
 free_lun,il

 For I = 0, N_elements(State)-1 do begin
   Case State[I] of
        'AK' : Statename[I] = 'Alaska'
        'WA' : Statename[I] = 'Washington'
        'OR' : Statename[I] = 'Oregon'
        'CA' : Statename[I] = 'California'
        'NV' : Statename[I] = 'Nevada'
        'ID' : Statename[I] = 'Idaho'
        'MT' : Statename[I] = 'Montana'
        'UT' : Statename[I] = 'Utah'
        'AZ' : Statename[I] = 'Arizona'
        'WY' : Statename[I] = 'Wyoming'
        'CO' : Statename[I] = 'Colorado'
        'NM' : Statename[I] = 'New Mexico'
        'ND' : Statename[I] = 'North Dakota'
        'SD' : Statename[I] = 'South Dakota'
        'NE' : Statename[I] = 'Nebraska'
        'KS' : Statename[I] = 'Kansas'
        'OK' : Statename[I] = 'Oklahoma'
        'TX' : Statename[I] = 'Texas'
        'MN' : Statename[I] = 'Minnesota'
        'IA' : Statename[I] = 'Iowa'
        'MO' : Statename[I] = 'Missouri'
        'AR' : Statename[I] = 'Arkansas'
        'LA' : Statename[I] = 'Louisiana'
        'WI' : Statename[I] = 'Wisconsin'
        'IL' : Statename[I] = 'Illinois'
        'MS' : Statename[I] = 'Mississippi'
        'MI' : Statename[I] = 'Michigan'
        'IN' : Statename[I] = 'Indiana'
        'OH' : Statename[I] = 'Ohio'
        'KY' : Statename[I] = 'Kentucky'
        'WV' : Statename[I] = 'West Virginia'
        'TN' : Statename[I] = 'Tennessee'
        'AL' : Statename[I] = 'Alabama'
        'GA' : Statename[I] = 'Georgia'
        'FL' : Statename[I] = 'Florida'
        'ME' : Statename[I] = 'Maine'
        'VT' : Statename[I] = 'Vermont'
        'NH' : Statename[I] = 'New Hampshire'
        'MA' : Statename[I] = 'Massachusetts'
        'RI' : Statename[I] = 'Rhode Island'
        'CT' : Statename[I] = 'Connecticut'
        'NJ' : Statename[I] = 'New Jersey'
        'NY' : Statename[I] = 'New York'
        'PA' : Statename[I] = 'Pennsylvania'
        'DE' : Statename[I] = 'Delaware'
        'DC' : Statename[I] = 'Washington DC'
        'MD' : Statename[I] = 'Maryland'
        'VA' : Statename[I] = 'Virginia'
        'NC' : Statename[I] = 'North Carolina'
        'SC' : Statename[I] = 'South Carolina'
        'VI' : Statename[I] = 'Virgin Islands'
        'HI' : Statename[I] = 'Hawaii'
        ELSE : begin
               print, State[I] 
               stop
               end
      Endcase
  Endfor

 Info = {Siteid:Site, Name:Name, State:State, Statename:Statename, $
         Lon:Lon, Lat:Lat, Elev:Elev}

 Return, Info

 end

