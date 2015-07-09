FUNCTION  IN, ITEM,SET,OPER

;+
; NAME:
;	IN
; PURPOSE:
;	Checks if a value is found in a specified set.  Returns the position
;		of the value in the set. Returns -1 if the value is not in
;		the set.
; CATEGORY:
;	array
; CALLING SEQUENCE:
;	POS = IN(ITEM,SET,OPER)
; INPUTS:
;	ITEM	(ANY)	= Array of values to be checked.
;	SET	(ANY)	= Array of values to compare with.
; OPTIONAL INPUTS:
;	OPER	(ANY)	= Operator (ITEM op SET)
;				0 = equal
;				1 = gt
;				2 = lt
;				3 = ge
;				4 = le
; OUTPUTS:
;	FUNCTION RESULT	= Returns the position of each element in ITEM in the 
;				array SET.
;				Returns -1 if ITEM is not in SET.
; COMMON BLOCKS:
;	None
; SIDE EFFECTS:
;	None.
; RESTRICTIONS:
;	None.
; PROCEDURE:
;	Uses where for each element of ITEM.
; MODIFICATION HISTORY:
;    written by Eric Nash
;-

; *****Number of elements in item
  n=n_elements(item)
  result=lonarr(n)

; *****Default operator (=)
  if  (n_elements(oper) eq 0)  then  oper=0

; *****Use appropriate operator
  case  oper  of

;	*****gt
    1 : for  i=0,n-1  do  begin

;	  *****Determine if item is in set
	  s=where(item(i) gt set)

;	  *****Returns location of ITEM in SET
	  result(i)=s(n_elements(s)-1l)
	endfor

;	*****lt
    2 : for  i=0,n-1  do  begin

;	  *****Determine if item is in set
	  s=where(item(i) lt set)

;	  *****Returns location of ITEM in SET
	  result(i)=s(0)
	endfor

;	*****ge
    3 : for  i=0,n-1  do  begin

;	  *****Determine if item is in set
	  s=where(item(i) ge set)

;	  *****Returns location of ITEM in SET
	  result(i)=s(n_elements(s)-1l)
	endfor

;	*****le
    4 : for  i=0,n-1  do  begin

;	  *****Determine if item is in set
	  s=where(item(i) le set)

;	  *****Returns location of ITEM in SET
	  result(i)=s(0)
	endfor

;	*****eq
	else : for  i=0,n-1  do  begin

;	  *****Determine if item is in set
	  s=where(item(i) eq set)

;	  *****Returns location of ITEM in SET
	  result(i)=s(0)
	endfor
  endcase

; *****Set result to scalar for 1 element
  if  (n_elements(result) eq 1)  then  result=result(0)

  return,result
END
