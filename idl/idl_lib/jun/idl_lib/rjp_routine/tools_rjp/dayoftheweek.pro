pro CAL_INFO, MONTH, YEAR, START_SQUARE, NUM_DAYS

L_MONTH = MONTH - 1
MONTHS = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

DAY = (JULDAY(1, 1, YEAR) + 1) MOD 7
DAY1_NEXT_YEAR = (JULDAY(1, 1, YEAR+1) + 1) MOD 7

case ((DAY1_NEXT_YEAR + 7 - DAY) mod 7) of
	2 :
	1 : MONTHS[1] = 28	; Not a leap year
	else: MONTHS[8] = 19	; 1752
	endcase

for I = 0, L_MONTH - 1 do DAY = DAY + MONTHS[I]
START_SQUARE = (DAY MOD 7)
NUM_DAYS = MONTHS[L_MONTH]
end


pro dayoftheweek, Month, Year, Date=Date, DOW=DOW

  MONTHS = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG', $
	      'SEP','OCT','NOV','DEC']

; Process the input
NP = n_params()
case NP of
	0: begin
	    DATE = systime()
	    L_MONTH = long(where(strupcase(strmid(DATE, 4, 3)) eq MONTHS))
	    L_MONTH = L_MONTH[0] + 1	; Scalarize it...
	    L_YEAR = long(strmid(DATE, 20, 4))
	    end
	1: begin
	    L_YEAR =LONG(MONTH)		; Only 1 parm, take it as year
	    L_MONTH=LINDGEN(12)+1L
	    end
	2: begin
	    L_MONTH = LONG(MONTH)
	    L_YEAR=LONG(YEAR)
	    end
	else: message, 'Wrong number of parameters.'
	endcase

  weeks = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat','Sun']

  Date = ''
  DOW  = ''
  for I = 0, N_elements(L_MONTH)-1 do begin
      cal_info, L_month[I], L_year, sq, Nday

      For N = 0, Nday-1 do begin
          Day  = strtrim(L_month[I],2)+'/'+strtrim(N+1,2)+'/'+strtrim(L_year,2)
          Date = [Date, Day]
          DOW  = [DOW,  weeks[((N+sq) mod 7)]]
      Endfor
  endfor

  Date = Date[1:*]
  DOW  = DOW[1:*]
       

 end
