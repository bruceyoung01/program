

  ; 
  ; Read AIRS PM2.5
  ;

  filename = 'new_site_monitor.txt'
  readcol, filename, class, action, state, county, site, $
           lat, lon, delimiter='|', $
           format='(A,A,A,A,A,F,F)', $
           skipline=1, /debug


  ; get month, day, year
 ; yr = period/10000
 ; mon = (period-yr*10000)/100
 ; day = (period-yr*10000 - mon*100)

  ; print out 
  i = 0L
  openw, 1, 'Simple_' + filename
  printf, 1, 'class state county site yr mn dd lat lon'
   classcount=n_elements(class)-2
   for i=0, classcount do begin
    if (class[i] eq 'AA') then begin 
    printf, 1, class[i], state[i], county[i], site[i], lat[i], lon[i], $
             format='(A, 1X,  A, 1X,  A, 1X, A, 1X, f8.1, 1X, f8.1)'
    endif
   endfor
  close,1 

  end   
