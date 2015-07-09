pro ncdfshow,outfile
; this procedure will read and display the attributes
; for every variable found in a netCDF file
; input file will be found by an interactive search
; output file will be text of the information gathered.
;
; COMMAND LINE USAGE: > ncdfshow,'outfilename'
; note that 'outfilename' is a string and must be in quotes.
;
; With the outfile information in hand, the data can be retrieved
; using the commands below, with user input marked by '*'
; and input from the outfile marked by '#'
; the user must supply variable names to store the ID numbers
; created for the file and variable...'fileID' and 'varID' are used here.
; the user must also supply the name of a variable in which to put the data.
; here this is called 'variable_array', but any name would work.
;
; fileID = NCDF_OPEN('filename'*)
; varID = NCDF_VARID(fileID, 'varname'#)
; NCDF_VARGET, fileID, varID, variable_array
; NCDF_CLOSE, fileID
;
; note that 'filename' and 'varname' are strings and must be in quotes
; 'varname' must be exactly as provided in the netCDF file
;_____________________________________

netcdf_directory = '/Users/brianvanthull/GOES/'

; open the output file
openw,1,netcdf_directory+outfile

; find input file and produce a file ID
filename = dialog_pickfile(path=netcdf_directory)
fileID = ncdf_open(filename)

;find the number of variables
fileinq_struct = ncdf_inquire(fileID)
nvars = fileinq_struct.nvars

; print output so far
printf,1,filename
printf,1, nvars, ' variables in file'
printf,1, ' '
printf,1, ' '

;loop through variables
for varndx = 0,nvars-1 do begin

   ; get the name, datatype, dims, number of attributes
     varstruct = ncdf_varinq(fileID,varndx)

   ; print the variable index, name, datatype, dims
     printf,1, '--------------------------------------------------------'
     printf,1,varndx,'    ',varstruct.name, '     ',varstruct.datatype
     printf,1,'dims = ',varstruct.dim

   ; loop through attributes
     for attndx = 0, varstruct.natts-1 do begin

       ; get attribute name, then use it to get the value
         attname = ncdf_attname(fileID,varndx,attndx)
         ncdf_attget,fileID,varndx,attname,value

       ; print name and value to file
         printf,1,attname, '     ',string(value)
    
     endfor ; attribute loop

endfor ; variable loop

; close in and out files
close,1
ncdf_close,fileID

print,'output saved as ',netcdf_directory+outfile

end

