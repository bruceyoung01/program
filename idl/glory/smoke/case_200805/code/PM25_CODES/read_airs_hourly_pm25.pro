

  ; 
  ; Read AIRS PM2.5/SO2
  ;

  filename = 'New_RD_501_88502_2009-0.txt'
  readcol, filename, v1, v2, state_id, county_id, site_id, $
           parameter_id, poc, unit, method, v4,  period, $
           time, samples, delimiter='|', $
           format='(A,A,A,A,A,L,I,I,I,I,L,A,f,X,X,X,X,X,X,X,X,X,X,X,X,X,X)', $
           skipline=2, /debug

  ; get month, day, year
  yr = period/10000
  mon = (period-yr*10000)/100
  day = (period-yr*10000 - mon*100)

  ; print out 
  i = 0L
  openw, 1, 'Simple_' + filename
  printf, 1, 'state_id county_id site_id yr mn dd time sample'
   while ( i le n_elements(yr)-2 ) do begin 
    printf, 1, state_id[i], county_id[i], site_id[i], yr[i], $
             mon[i], day[i], time[i], samples[i], $
             format='(A, 1X,  A, 1X,  A, 1X, I4, 1X, I2, 1X, I2, 1X, A, 1X, f8.1)'
   i = i + 1L
   endwhile
  close,1 

  end   
