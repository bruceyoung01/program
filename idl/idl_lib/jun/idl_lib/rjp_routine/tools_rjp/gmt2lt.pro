
 function gmt2lt, gmt, lon

; convert gmt clock to local time clock


 ; Local Time = GMT + ( longitude / 15 ) since each hour of time
 ; corresponds to 15 degrees of longitude on the globe
 THISLOCALTIME = GMT + round( lon / 15. )
      
 For D = 0, N_elements(Thislocaltime)-1 do begin
 ; Make sure that THISLOCALTIME is in the range 0-24 hours
    IF ( THISLOCALTIME[d] gt 24 ) then THISLOCALTIME[d] = THISLOCALTIME[d] - 24.
    IF ( THISLOCALTIME[d] lt 0  ) then THISLOCALTIME[d] = THISLOCALTIME[d] + 24.
    IF ( THISLOCALTIME[d] eq 24 ) then THISLOCALTIME[d] = 0.
 End

 return, THISLOCALTIME

 end
