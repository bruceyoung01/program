FUNCTION POSITION_GET, col, row, left, bot, right, top, col_mar, row_mar
;left,bottom, right,top
pos=fltarr(col, row,4)

length = (top-bot-row_mar*(row-1.))/float(row)
width = (right-left-col_mar*(col-1.))/float(col)
if (length LT 0.) OR (width LT 0.) then begin
	print, 'ERROR: margin of col or row too large !
	return, 0
endif
if (left GT 1.) OR (bot GT 1) OR (right GT 1.) OR (top GT 1.) then begin
	print, 'ERROR: the border is greater than 1!
	return, 0
endif

if (left LT 0.) OR (bot LT 0) OR (right LT 0.) OR (top LT 0.) then begin
	print, 'ERROR: the border is less than 1!'
	return, 0
endif

pos[0,*,0] = left
pos[*,row-1,1] = bot
pos[col-1,*,2] = right
pos[*,0,3] = top


FOR i = 0, col -1 DO BEGIN
  FOR j = 0, row - 1 DO BEGIN
    pos[i,j,0] = left + i* (width + col_mar)
    pos[i,j,1] = bot  + (row - j -1) *(length + row_mar)
    pos[i,j,2] = right - (col - i -1) *(width + col_mar)
    pos[i,j,3] = top - j * (length + row_mar)
  ENDFOR
ENDFOR
return, pos

END
