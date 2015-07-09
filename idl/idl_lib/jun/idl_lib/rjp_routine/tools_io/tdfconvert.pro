
; this is idl routine to read tab dilimiated data file
; and return them as string variables

 function tdfconvert, input

 ; first convert input into byte data
  bit = byte(input)
  pos = where(bit eq 9) ; 9 is tab in byte

  if N_elements(pos[0]) eq -1 then begin
   print, 'No data in this input'
   return, -1
  end

    Array = ''
    ic = -1L
    is = 0L
  for D = 0, n_elements(pos)-1L do begin
    ie = pos[D]-1L
    if (is ge 0L) and (ie ge is) then begin
        Array = [Array, string(bit[is:ie])]
    end
    is = pos[D]+1L
   end

    ie = n_elements(bit)-1L
    if (is ge 0L) and (ie ge is) then begin
        Array = [Array, string(bit[is:ie])]
    end

 return, strtrim(Array[1:*])
 
 end
