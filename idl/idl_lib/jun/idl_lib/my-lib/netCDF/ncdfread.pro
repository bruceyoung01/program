pro ncdfread, filename,variable_name, data_variable, dims
; This procedure will read netCDF data and place it in an IDL variable 
; INPUT: filename - a string variable that includes the filepath
;        variable_name - a string that must match exactly that produced by        
;                        ncdfshow.pro
; OUTPUT: data_variable - a user supplied variable for the data
;         dims - a vector of the dimensions

; get fileID, variable ID
  fileID = ncdf_open(filename)
  varID = ncdf_varid(fileID,variable_name)

; get the data and dimensions
  ncdf_varget,fileID, varID, data_variable
  dims = size(data_variable,/dimensions)

end
