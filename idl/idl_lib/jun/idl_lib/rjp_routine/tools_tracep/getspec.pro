pro getspec,data,header,species,sname,$
	newname=newname,transpose=transpose, factor=factor

ind = where(header eq sname,c)
if not keyword_set(factor) then factor=1.0
if n_elements(ind) gt 1 then begin
	print,'*** WARNING ! More than one element found:',sname
	ind=ind(0)
endif

if (c eq 0) then begin
   print,'*** WARNING ! Species ',sname,' not found !'
   species = fltarr(n_elements(data(0,*)))-999.99
   return
endif
if n_elements(data(ind,*)) eq n_elements(header) then $
     species = data(*,ind)*factor else species = data(ind,*)*factor
if (keyword_set(newname)) then header(ind) = newname
if (keyword_set(transpose)) then species=transpose(species)

return
end
