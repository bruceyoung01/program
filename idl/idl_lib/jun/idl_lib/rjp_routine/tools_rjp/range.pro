function range, data

 if n_elements(data) gt 0 then return, [min(data), max(data)] $
 else return, -1

end
