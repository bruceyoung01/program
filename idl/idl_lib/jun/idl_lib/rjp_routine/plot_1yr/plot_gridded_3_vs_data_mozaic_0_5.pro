; $Id: plot_gridded_3_vs_data_mozaic_0_5.pro,v 1.2 2005/03/10 15:52:14 bmy Exp $
pro plot_gridded_3_vs_data_mozaic_0_5, Species, max_sta, ext1,   ext2,  $
                                       ext3,    title,   psname, filest

   ; For selected regions from aircraft compains plot data profiles (black
   ; solid line and profiles from 3 models - with maccm3, dao and giss 
   ; winds, plotted with linestyles 1 to 3 and colors red, green and blue 
   ; correspondently

   ; Modified to read station files from the temp/ subdirectory (bmy, 3/7/05)

   ;=======================================================================
   ; Initialization 
   ;=======================================================================

   !X.OMARGIN=[10,8] 
   !Y.OMARGIN=[8,8]
   !P.CHARTHICK=3
   !P.THICK=4.5
   !X.THICK=4
   !Y.THICK=4

   ; Open file with information about stations
   openr, usta, filest, /get_lun
   iname_sta=''
   ititle_sta=''

   mmonth = strarr(12)
   mmonth=['Jan','Feb','Mar','Apr','May','Jun',$
           'Jul','Aug','Sep','Oct','Nov','Dec']

   pressure_sonde=fltarr(70)
   pressure_sonde=[962.35  ,891.25  ,825.41  ,764.42  ,707.94  ,$
                   655.64  ,607.20  ,562.34  ,520.80  ,482.32  ,$
                   446.69  ,413.69  ,383.12  ,354.81  ,328.60  ,$
                   304.32  ,281.84  ,261.02  ,241.73  ,223.87  ,$
                   207.33  ,192.01  ,177.82  ,164.69  ,152.52  ,$
                   141.26  ,130.82  ,121.15  ,112.20  ,103.91  ,$
                    96.23  , 89.12  , 82.54  , 76.44  , 70.79  ,$
                    65.57  , 60.72  , 56.23  , 52.08  , 48.23  ,$
                    44.67  , 41.37  , 38.31  , 35.48  , 32.86  ,$
                    30.43  , 28.18  , 26.10  , 24.17  , 22.38  ,$
                    20.73  , 19.20  , 17.78  , 16.47  , 15.25  ,$
                    14.12  , 13.08  , 12.12  , 11.22  , 10.39  ,$
                     9.62  ,  8.91  ,  8.25  ,  7.64  ,  7.08  ,$
                     6.56  ,  6.07  ,  5.62  ,  5.21  ,  4.82  ]

   scales=[320,320,320,320,320,320,320,320]

   open_device,olddevice,/ps,/color,filename=psname,/portrait

   ; Specify directory with the data (vertical profiles) 

   pre = '/data/eval/aircraft/data/'+species+'/'
   xtitle = 'CO (ppb)' 

   ;=======================================================================
   ; --- read station & indice ---
   ;=======================================================================

   name_sta = strarr(max_sta)
   month    = fltarr(max_sta)
   lol      = fltarr(max_sta)
   lor      = fltarr(max_sta)
   lad      = fltarr(max_sta)
   lau      = fltarr(max_sta)
   H        = fltarr(max_sta)
   year     = intarr(max_sta)
   title_sta = strarr(max_sta)
   num_sta  =strarr(max_sta)

   ; Read in information about stations from input file

   for i=0,max_sta-1 do begin
      readf,usta, iname_sta,                  $
         ilol, ilor, ilad, ilau,          $
         imonth , iH, iyear, ititle_sta,inum_sta,         $
         format='(a36,1x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i2,1x,a24,1x,a3)'
      name_sta(i) = iname_sta
      month(i)    = imonth
      lol(i)      = ilol
      lor(i)      = ilor
      lad(i)      = ilad
      lau(i)      = ilau
      H(i)        = iH
      year(i)     = iyear
      title_sta(i) = ititle_sta
      num_sta(i) = inum_sta
   endfor

   ; Set number of rows and columns
   nrow=3
   ncol=3
   !P.Multi = [0,nrow,ncol,1,0]

   ;=======================================================================
   ; ---  open files ---
   ;=======================================================================
   ncount=0

   ; Loop through the stations
   for k = 1, max_sta do begin
      
      ncount=ncount+1
      kk = k-1 
      ix = k
      file=''

      ;====================================================================
      ; Get name of CO data profile
      ;====================================================================
      name_sonde=''
      name_sonde='/users/trop/iam/co.prof.for.gmi/co.prof.'+$
         strtrim(String(fix(num_sta(kk))),2)+'.0.5'
      read_sondes_co_0_5, name_sonde, month(kk), month(kk), month(kk), $
                          month(kk),  sonde1,    std1,      sonde2,    $
                          std2,       sonde3,    std3,      sonde4, std4
      
      inds1 = Where(pressure_sonde ge 200 and sonde1>0)
      sonde1_p=sonde1[inds1]
      std1_p=std1[inds1]
      pressure_sonde1_p=pressure_sonde[inds1]

      ; Station title
      ltitle=''
      ltitle = strtrim(title_sta(kk),2)

      ;====================================================================
      ; -- plot observed data --
      ;====================================================================
      yrange = [1000, 100]
      height = 0
      mmm = 230

      highval=scales(k-1)
      loval=0
      if highval ge 300 then loval = 60

      ytickv = [1000,800,600,400,200]
      ytickname = ['1000','800','600','400','200']

      ; Plot medians
      plot,sonde1_p, pressure_sonde1_p, xstyle=1,ystyle=1,/ylog,$
         title=ltitle,linestyle=0,psym=-5,symsize=0.6,/nodata,$
         yticks=n_elements(ytickv)-1,ytickv=ytickv,ytickname=ytickname,$
         xticks=4, min_val=-900, yrange=[1000,200], xrange=[loval,highval],$
         charsize=1.8, xmargin=[4,3], ymargin=[3,2],color=1

      oplot, sonde1_p, pressure_sonde1_p,psym=0, $
         symsize=0.2,linestyle=0,color=1

      ; Put error bars (one standard deviation) for sonde data
      levs=n_elements(sonde1_p)
      for w = 0, levs-1 do begin
         if std1_p(w) gt 0 then begin
            errbar = [sonde1_p(w)-std1_p(w), sonde1_p(w)+std1_p(w)]
            oplot, errbar, [pressure_sonde1_p(w),pressure_sonde1_p(w)],$
               linestyle=0,color=1
         endif
      endfor
     
      howfarover  = 0.8*highval
      howfarover2 = highval*0.5

      ;====================================================================
      ; -- read results from the first model --
      ;====================================================================
      xdata=fltarr(19)
      xlevel=fltarr(19)
      A = fltarr(2)
      filef ='' 
      filef =  'temp/' + strtrim(name_sta(kk),2)+ext1

      result = findfile(filef, count = toto)
 
      pressure=fltarr(19)       
      co=fltarr(19)            

      openr,ix,filef
      for j = 1,19 do begin     ;19 levels 
         jx = j - 1
         readf, ix, fpres, fco,format='(f13.3,f13.4)'
         pressure[jx]=fpres
         co[jx]=fco
      endfor

      close,ix

      zz = fltarr(16)
      ZZ = FINDGEN(16) * (!PI*2./16.)
      USERSYM, COS(zz), SIN(zz) ;  , /FILL

      ; Plot profile from the first model
      oplot,co,(pressure),psym=0, symsize=0.2,linestyle=0,color=2

      ;====================================================================
      ; -- read results from the second model --
      ;====================================================================
      xdata=fltarr(19)
      xlevel=fltarr(19)
      A = fltarr(2)
      filef ='' 
      filef =  'temp/' + strtrim(name_sta(kk),2)+ext2

      result = findfile(filef, count = toto)
 
      pressure=fltarr(19)   
      co=fltarr(19)             

      openr,ix,filef
      for j = 1,19 do begin     ;19 levels
         jx = j - 1
         readf, ix, fpres, fco,format='(f13.3,f13.4)'
         pressure[jx]=fpres
         co[jx]=fco
      endfor

      close,ix

      zz = fltarr(16)
      ZZ = FINDGEN(16) * (!PI*2./16.)
      USERSYM, COS(zz), SIN(zz) ;  , /FILL

      ; Plot profile from the 2nd model
      oplot,co,(pressure),psym=0, symsize=0.2,linestyle=0,color=3

      ;====================================================================
      ; -- read results from the third model --
      ;====================================================================
      xdata=fltarr(19)
      xlevel=fltarr(19)
      A = fltarr(2)
      filef ='' 
      filef = 'temp/' + strtrim(name_sta(kk),2)+ext3
      ;print,filef
      
      result = findfile(filef, count = toto)
 
      pressure=fltarr(19)       
      co=fltarr(19)             
      
      openr,ix,filef
      for j = 1,19 do begin     ;19 levels
         jx = j - 1
         readf, ix, fpres, fco,format='(f13.3,f13.4)'
         pressure[jx]=fpres
         co[jx]=fco
      endfor

      close,ix
      
      zz = fltarr(16)
      ZZ = FINDGEN(16) * (!PI*2./16.)
      USERSYM, COS(zz), SIN(zz) ;  , /FILL

      ; Plot profile from 3rd model
      oplot,co,(pressure),psym=0, symsize=0.2,linestyle=0,color=4

      ; Put labels on the axes
      xyouts, 0.05, 0.65, 'Pressure (hPa)', /normal, align=0.5, $
         orientation=90, charsize=1.2,color=1
      xyouts, 0.5, 0.33, 'CO (ppb)', /normal, align=0.5, charsize=1.,color=1
      xyouts, 0.5,0.95, title, /normal, align=0.5, charsize=1.2,color=1

   endfor 

   close_device, /TIMESTAMP

   close, /all

end


