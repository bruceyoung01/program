 pro read_raw, us=us, cn=cn

 hd = ' '
 openr, il, 'wildfires.csv', /get

 readf, il, hd
 tag = csvconvert(hd)

 usw = ' '
 ; us wildfire (acres)
 For d = 0, 1 do  readf, il, hd
 For d = 0, 10 do begin
   readf, il, hd
   dat = csvconvert(hd)
   usw = [usw, dat]
 end
 usw = usw[1:*]
 usw = reform(usw, n_elements(tag), 11)

 usp = ' '
 ; us prescribed fire (acres)
 For d = 0, 1 do  readf, il, hd
 For d = 0, 10 do begin
   readf, il, hd
   dat = csvconvert(hd)
   usp = [usp, dat]
 end
 usp = usp[1:*]
 usp = reform(usp, n_elements(tag), 11)

 caw = ' '
 ; canada wildfire (ha)
 For d = 0, 1 do  readf, il, hd
 For d = 0, 12 do begin
   readf, il, hd
   dat = csvconvert(hd)
   caw = [caw, dat]
 end
 caw = caw[1:*]
 caw = reform(caw, n_elements(tag), 13)

 free_lun, il

 Region = Reform(usw[0,*])
 Year   = Long(Tag[1:*])
 usw    = Float(usw[1:*,*])*0.405  ; convert from Acres to ha
 usp    = Float(usp[1:*,*])*0.405

 For D = 0, n_elements(Region)-1 do begin
     str = create_struct( 'region',region[D],      $
                          'year',year,             $
                          'WF', Reform(usw[*,D]),  $
                          'PF', Reform(usp[*,D])   )

     if D eq 0 then US = str else US = [US, str]
 End 


 Region = Reform(caw[0,*])
 Year   = Long(Tag[1:*])
 caw    = Float(caw[1:*,*])

 For D = 0, n_elements(Region)-1 do begin
     str = create_struct( 'region',region[D],      $
                          'year',year,             $
                          'WF', Reform(caw[*,D])   )

     if D eq 0 then CN = str else CN = [CN, str]
 End 

 end


 if n_elements(us) eq 0 then read_raw, us=us, cn=cn

 j = where(us[0].year ge 2001 and us[0].year le 2004)
 reg = us.region
 ide = [1, 7]
 idw = [2, 3, 4, 5, 6, 8, 9, 10]
 ida = [0]

 pf_us = total(us.pf[j],2)*1.e-6
 pf_sa = (us[7].pf[j])*1.e-6
 pf_w  = total(us[idw].pf[j],2)*1.e-6

 pf_ea = (us[1].pf[j])*1.e-6

 
 End
