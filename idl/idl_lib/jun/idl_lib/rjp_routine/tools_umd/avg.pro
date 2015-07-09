function avg,arr,d,badval=badval,total=total

if n_elements(d) eq 0 then d = 0
if n_elements(total) eq 0 then total = 0

if n_elements(badval) eq 0 then begin
  s = size(arr)
  n_values = s(d+1)
  return, sum(arr,d)/n_values
  end $
 else begin
   mask = (arr ne badval)
   masksum = sum(mask,d)
   goodpoint = where(masksum ne 0)
   badpoint = where(masksum eq 0,count)
   aout = sum(mask*arr,d)
   aout(goodpoint) = aout(goodpoint)/masksum(goodpoint)
   if(total ne 0) then aout(goodpoint) = aout(goodpoint)*masksum(goodpoint)
   if count gt 0 then aout(badpoint) = badval
   return, aout
 end
end
