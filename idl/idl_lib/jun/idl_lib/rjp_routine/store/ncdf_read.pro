;-------------------------------------------------------------
; $Id$
;+
; NAME:
;        NCDF_READ
;
; PURPOSE:
;        Open a netCDF file and read data from it. The data is 
;        returned as a structure whose tag names are the names of 
;        the variables with blanks etc. replaced. If no variables 
;        are specified with the VARIABLES keyword, only dimensional 
;        information is returned. You can load all variables using
;        the ALL keyword. Other keyword options include OFFSET, COUNT, STRIDE,
;        NO_DIMENSIONS, NO_STRUCT, DIMNAMES, VARNAMES, VARDIMS, ATTRIBUTES.
;        Thus, this program includes ncdump functionality.
;        If no filename is given, a file selection dialog is
;        opened with the default mask '*.nc'. The name of the selected
;        file is returned in the TRUENAME keyword. A file selection
;        dialog also appears when the file cannot be found (see
;        OPEN_FILE.PRO). This can be turned off with the NO_DIALOG
;        keyword. The VERBOSE keyword provides information while
;        analyzing and reading the file.
;
; AUTHOR:
;        Dr. Martin Schultz
;        Max-Planck-Institut fuer Meteorologie
;        Bundesstr. 55, D-20146 Hamburg
;        email: martin.schultz@dkrz.de
;        
; CATEGORY:
;        File I/O
;
; CALLING SEQUENCE:
;        NCDF_READ, result, filename=<string>, truename=<string>,
;            variables=<stringarray>, all=<flag>, varnames=<stringarray>, 
;            vardimid=<structure>, vardims=<structure>, attributes=<structure>,
;            count=<integerarray>, offset=<integerarray>, stride=<integerarray>, 
;            dimnames=<stringarray>, dims=<longarray>, no_dimensions=<flag>,
;            no_struct=<flag>, no_dialog=<flag>, verbose=<flag>, title=<string>
;
; ARGUMENTS:
;        RESULT(out) -> a structure containing all the variable data
;             from the netCDF file. If only one variable is specified 
;             and the NO_STRUCT keyword set, then RESULT will be an
;             array instead of a structure. Use the ALL keyword
;             to load all variables at once. Note, that the COUNT, OFFSET,
;             and STRIDE keywords can affect the size of RESULT.
;             RESULT is set to -1L if an error occurs before the structure
;             has been built. You can use CHKSTRU.PRO to test for this.
;
; KEYWORD PARAMETERS:
;        FILENAME(in) -> the name of the netCDF file to be opened.
;             NCDF_READ uses OPEN_FILE to check the validity of
;             the file first. You can specify a search mask
;             instead of a filename in which case a file selection
;             dialog is displayed (unless you set the NO_DIALOG
;             keyword). The TRUENAME keyword contains the name
;             of the selected file or an empty string if the
;             file selection was canceled.
;
;        TRUENAME(out) -> the (fully qualified) name of the file selected
;             with the file selection dialog or an unaltered copy
;             of FILENAME if FILENAME is a valid filename.
;
;        VARIABLES(in) -> a string array containing the names of variables
;             for which data shall be read. Default is to read 
;             only the dimensional information from the file. 
;             (Currently) no warning is issued if a variable is not in the file.
;
;        ALL(in) -> set this keyword to load all variables stored in the 
;             netCDF file. Generally, you cannot usethis keyword together with
;             COUNT, OFFSET, and STRIDE.
;
;        VARNAMES(out) -> a string array containing the names of all variables 
;             as stored in the file. Note, that the tag names of e.g. the
;             result structure are filtered with the Valid_TagName function.
;             
;        VARDIMID(out) -> a structure with integer arrays containing the 
;             dimension ID's for all variables. See also VARDIMS which returns
;             the dimensions themselves.
;
;        VARDIMS(out) -> a structure with integer arrays containing the 
;             dimensions for all variables in the netCDF file. These are not
;             kept in sync with potential COUNT, OFFSET, and STRIDE values,
;             but reflect the data sizes as stored in the file.
;
;        ATTRIBUTES(out) -> a structure holding the variable and global
;             attributes stored in the netCDF file (global attributes
;             are stored in tag name GLOBAL). 
;
;        COUNT(in) -> an integer array containing the number of values to
;             be read for each dimension of the variables. Mapping of the
;             COUNT dimensions to the variable dimensions is achieved via
;             the first entry in the VARIABLES list and the COUNT parameter
;             will be applied to all variables that have that dimension. 
;             Example: The first variable has dimensions LON, LAT, LEV,
;             the second variable has dimensions LON, LAT, and the third
;             variable has LAT, LEV. A COUNT of [40,20,10] would lead to
;             result dimensions of [40,20,10], [40,20], and [20,10].
;
;        OFFSET(in) -> an integer array containing the offsets for each
;             dimension of the variables to be read. Dimension mapping
;             is the same as for COUNT.
;
;        STRIDE(in) -> an integer array containing the stride for each
;             dimension of the variables to be read. Dimension mapping
;             is the same as for COUNT.
;             
;        DIMNAMES(out) -> a string array containing the names of the 
;             dimensions stored in the netCDF file.
;
;        DIMS(out) -> a long array containing the dimension values. Purely
;             for convenience. Use VARDIMS to retrieve the dimensions of
;             the variables.
;
;        TITLE(in) -> A title for the file selection dialog if an
;             incomplete or incorrect filename is specified. This
;             keyword is ignored if the no_dialog keyword is set.
;
;        NO_DIMENSIONS(in) -> set this keyword if you do not want to store
;             the dimensional variables from the file in the result structure. 
;             DIMNAMES and DIMS will still be retrieved.
;
;        NO_STRUCT(in) -> if only one variable is selected with the
;             VARIABLE keyword, you can set this keyword to return only
;             the data for this variable as an array. This keyword implies
;             the functionality of NO_DIMENSIONS.
;
;        NO_DIALOG(in) -> set this keyword if you do not want interactive 
;             behaviour when a file mask is given instead of a filename or
;             when the specified file does not exist.
;
;        VERBOSE(in) -> set this keyword to get detailed information while
;             reading the netCDF file.
;
; SUBROUTINES:
;        Valid_TagName : replaces invalid characters in variable names so that
;            a structure can be built.
;      
;        ncdf_attributes : retrieves global and variable attributes from netcdf
;            file and stores them as structure.
;
;        ncdf_dimensions : retrieves size and name for all dimensions in netcdf file.
;
;        ncdf_varnames : retrieves names and dimension information for all variables
;            in the netCDF file.
;
;        ncdf_mapdims : map dimension indices for COUNT, OFFSET, and STRIDE with 
;            dimensions of first selected variable.
;
;        ncdf_TestDimensions : compute the COUNT, OFFSET, and STRIDE vectors that
;            must be applied for retrieving the data of one variable.

; REQUIREMENTS:
;        uses OPEN_FILE and STRREPL.
;
; NOTES:
;        Correct handling of dimensional information requires that the variables
;        storing the dimension values have the same name as the dimensions
;        themselves - a common feature in most netCDF standards.
;
;        I am still working on a netcdf file object which will be even
;        more powerful. At some point ncdf_read will only be a
;        procedure interface to this objec!
;
; EXAMPLE:
;        ncdf_read,result,/All
;        ; plot ozone vs. temperature
;        plot,result.temperature,result.ozone
;
; MODIFICATION HISTORY:
;        mgs, 18 Sep 1999: VERSION 1.00
;        mgs, 29 Feb 2000: - added variables keyword
;                          - added CATCH error handler
;        mgs, 21 Mar 2000: - bug fix for tag names
;        mgs, 09 May 2000: VERSION 2.00
;                          - now only reads dimensions as default
;                          - added ALL keyword to compensate
;                          - returns dimnames and attributes
;                            (makes ncdf_detail obsolete)
;                          - added COUNT, OFFSET and STRIDE keywords
;                          - added NO_DIMENSIONS and NO_DIALOG
;                            keywords and more
;        mgs, 22 Aug 2000: - added title keyword
;
;-
;-------------------------------------------------------------
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 1999-2000, Martin Schultz, Max-Planck Institut fuer 
; Meteorologie, Hamburg
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;-------------------------------------------------------------

;=============================================================
; Valid_TagName: replace invalid characters in netCDF variable names
;   to allow building of a structure.

function Valid_TagName, arg

      t = strrepl(arg,'-','_')
      t = strrepl(t,'+','P')
      t = strrepl(t,'$','D')
      t = strrepl(t,'*','S')
      t = strrepl(t,'&','_')
      t = strrepl(t,' ','_')
      t = strrepl(t,'@','_')

      return, t

end


;=============================================================
; ncdf_attributes: retrieve global or variable attributes from
; netCDF file. If keyword GLOBAL is not set, a variable ID must
; be supplied.
; The result is a structure with all global attributes or all
; attributes for one variable.

function ncdf_attributes, ncid, varid, global=global, verbose=verbose

    result = ''

    ; a little error checking
    if n_elements(varid) eq 0 and not keyword_set(global) then begin
       message,'Must supply VARID if keyword GLOBAL not set.',/Continue
       return, result
    endif

    ; get basic information about netCDF file
    nstru = NCDF_INQUIRE(ncid)

    ; determine number of attributes to be read
    if keyword_set(global) then begin
       natts = nstru.ngatts
    endif else begin
       vardesc = NCDF_VARINQ(ncid, varid)
       natts = vardesc.natts
    endelse
   
    if keyword_set(verbose) then begin
       if not keyword_set(global) then begin
          print, 'Attributes for variable ',vardesc.name
          prefix = '    '
       endif else begin
          prefix = 'Global attribute'
       endelse
    endif

    for i=0L,natts-1 do begin
       if keyword_set(global) then begin
          aname = NCDF_ATTNAME(ncid,/GLOBAL,i)
          NCDF_ATTGET,ncid, /GLOBAL, aname, avalue
          ainfo = NCDF_ATTINQ(ncid, /GLOBAL, aname)
          atype = ainfo.datatype
       endif else begin
          aname = NCDF_ATTNAME(ncid, varid, i)
          NCDF_ATTGET, ncid, varid, aname, avalue
          atype = size(avalue, /TNAME)
       endelse

       ; take care of IDL bug: CHAR is stored as BYTE
       ; assume all BYTES are CHARS (bug fixed in IDL5.3)
       if (atype eq 'BYTE') then $
          avalue = string(avalue)

       ; build or add to result structure
       newname = Valid_TagName(aname)
       if (i eq 0) then $
          result = create_struct( newname, avalue ) $
       else $
          result = create_struct( result, newname, avalue )

       if keyword_set(verbose) then begin
          print,prefix+aname+': '+avalue
       endif
    endfor

    return, result
end


;=============================================================
; ncdf_dimensions: retrieve dimension sizes and names from a 
; netCDF file. 

function ncdf_dimensions, ncid, names=names, verbose=verbose

    dims = -1L
    names = ''

    ; get basic information about netCDF file
    nstru = NCDF_INQUIRE(ncid)

; print,' ID of unlimited dimension : ',nstru.recdim
; print,'ID of time dimension : ',NCDF_DIMID(ncid, 'time')

    dims = lonarr(nstru.ndims)
    names = strarr(nstru.ndims)
    for i=0L,nstru.ndims-1 do begin
       NCDF_DIMINQ,ncid,i,dname,dsize
       names[i] = dname
       dims[i] = dsize
       if keyword_set(verbose) then $
          print,'Dimension '+strtrim(i,2)+': ',dname,dsize
    endfor

    return, dims
end


;=============================================================
; ncdf_varnames: retrieve variable names from a netCDF file. 
; this function also returns the variable dimension id's.

function ncdf_varnames, ncid, VarDimId=vardimid

    dims = -1L
    names = ''

    ; get basic information about netCDF file
    nstru = NCDF_INQUIRE(ncid)

    for i=0L,nstru.nvars-1 do begin
       vardesc = NCDF_VARINQ(ncid, i)
       if keyword_set(verbose) then print,'Variable '+vardesc.name+'  Dim-IDs: '  $
            + string(vardesc.dim,format='(12i6)')

       if i eq 0 then begin
          names = vardesc.name
          vardimid = create_struct( Valid_TagName(vardesc.name), vardesc.dim )
       endif else begin
          names = [ names, vardesc.name ]
          vardimid = create_struct( vardimid, Valid_TagName(vardesc.name), vardesc.dim )
       endelse
    endfor

    return, names
end


;=============================================================
; ncdf_mapdims: check compatibility of variable dimensions
;    with count, offset, and stride values. The dimensionality
;    for each of count, offset, and stride must be same as for
;    the variable (the first one asked for) or it can be 0,
;    i.e. the respective parameter is undefined.
;    If these conditions are met, the variable's vardimid array
;    establishes the link between the parameter dimension and the
;    physical dimension, otherwise a scalar -1L is returned.

function ncdf_mapdims,varname, vardimid,  $
                      count=count, offset=offset, stride=stride

    result = -1L

    nvdim = n_elements(vardimid)  ; dimensionality of variable
    nc = n_elements(count)
    no = n_elements(offset)
    ns = n_elements(stride)

    testc = (nc eq 0 OR nc eq nvdim)
    testo = (no eq 0 OR no eq nvdim)
    tests = (ns eq 0 OR ns eq nvdim)
    testnull = ( (nc > no > ns ) eq 0 )

    ok = ( testc AND testo AND tests ) AND not testnull
    if ok then result = vardimid

    return, result

end


;=============================================================
; ncdf_TestDimensions: check compatibility of variable dimensions
;    with count, offset, and stride values. The this... keyword
;    return valid entries for these parameters while the original
;    parameters remain unchanged.

function ncdf_TestDimensions, ncid, index, dims, mapdims, $
               count=count, offset=offset, stride=stride,  $
               thiscount=thiscount, thisoffset=thisoffset, thisstride=thisstride

; catch,/cancel
    result = 0    ; not compatible

    ; get variable information
    vardesc = NCDF_VARINQ(ncid, index)

    ; create default values
    ndims = n_elements(vardesc.dim)
    thiscount = dims[vardesc.dim]
    thisoffset = lonarr(ndims)
    thisstride = lonarr(ndims)+1L

; print,'variable ',vardesc.name
; print,'default thiscount=',thiscount
; print,'default thisoffset=',thisoffset
; print,'default thisstride=',thisstride

    for i=0L, n_elements(offset)-1 do begin
       w = where(vardesc.dim eq mapdims[i])
; print,'offset dimension ',i,' matches data dimension ',w
       if w[0] ge 0 then begin
          thisoffset[w] = offset[i] < (thiscount[w]-1)
          ; print,'new thisoffset=',thisoffset
          result = 1
       endif
    endfor

    for i=0L, n_elements(stride)-1 do begin
       w = where(vardesc.dim eq mapdims[i])
; print,'stride dimension ',i,' matches data dimension ',w
       if w[0] ge 0 then begin
          thisstride[w] = stride[i] > 1
          ; print,'new thisstride=',thisstride
          result = 1
       endif
    endfor

    for i=0L, n_elements(count)-1 do begin
       w = where(vardesc.dim eq mapdims[i])
; print,'count dimension ',i,' matches data dimension ',w
       if w[0] ge 0 then begin
          thiscount[w] = count[i] < ( (thiscount[w]-thisoffset[w])/thisstride[w] )
          thiscount[w] = thiscount[w] > 1
          ; print,'new thiscount=',thiscount
          result = 1
       endif
    endfor


    return, result

end


;=============================================================

pro NCDF_READ, result, filename=filename, truename=truename,    $
               variables=variables, all=all, attributes=attributes,        $
               varnames=varnames, vardimid=vardimid, vardims=vardims,      $
               count=count, offset=offset, stride=stride,                  $
               dimnames=dimnames, dims=dims, title=title,                  $
               no_dimensions=no_dimensions, no_struct=no_struct,           $
               no_dialog=no_dialog, verbose=verbose


   ; initialize
   result = -1L
   ilun = -1
   truename = ''
   dimnames = ''
   dims = -1L
   ErrMsg = '<unknown error>'
   IF N_Elements(title) EQ 0 THEN title = 'Open NetCDF file:'

   ; error handler
   catch, theError
   if theError ne 0 then begin
       catch,/Cancel
       if ilun gt 0 then free_lun,ilun
       if n_elements(truename) eq 0 then begin
           if n_elements(filename) gt 0 then $
             truename = filename  $
           else $
             truename = '<unknown>'
       endif

       Message,ErrMsg,/Continue
       return
   endif

   ; argument and keyword checking
   if (keyword_set(no_struct) AND n_elements(variables) ne 1) then begin
      message,'Keyword NO_STRUCT only valid if 1 variable selected.',/Continue
      return
   endif

   ; if no filename is passed we set '*.nc' as file mask
   if (n_elements(filename) eq 0) then $
      filename = '*.nc'
   ; for safety, we open the file first with OPEN_FILE
   ErrMsg = 'Error opening netCDF file '+filename
   open_file,filename,ilun,/BINARY,filename=truename,  $
       title=title,no_pickfile=no_dialog

   IF ilun le 0 THEN return

   if keyword_set(verbose) then $
       print,'Selected file ',truename
   free_lun,ilun
 
   ; now we know filename exists, so we can use NCDF_OPEN:
   ErrMsg = 'Error opening netCDF file '+truename
   id = NCDF_OPEN(truename)

   ErrMsg = 'Error reading netCDF file '+truename
   ; first find out about the file contents
   nstru = NCDF_INQUIRE(id)

   ; read dimensions from netCDF file
   dims = ncdf_dimensions(id, names=dimnames, verbose=verbose)

   ; retrieve the variable names and their dimension indices
   varnames = ncdf_varnames(id, vardimid=vardimid)

   ; service function: convert dimids to variable dimensions
   vardims = vardimid
   for i=0L, n_tags(vardimid)-1 do begin
      vardims.(i) = dims[vardimid.(i)]
      if keyword_set(verbose) then $
         print,'Variable '+varnames[i]+' : '+string(vardims.(i),format='(12i6)')
   endfor

   ; retrieve global and variable attributes (but only if requested)
   if arg_present(attributes) then begin
      gattr = ncdf_attributes(id, /Global, verbose=verbose)
      attributes = create_struct( 'GLOBAL', gattr)

      for i=0L,nstru.nvars-1 do begin
         vattr = ncdf_attributes(id, i, verbose=verbose)
         attributes = create_struct( attributes, Valid_TagName(varnames[i]), vattr)
      endfor
   endif 

   ; if at least one variable name is specified, use the first one to map
   ; potential offset, count, stride parameters to physical dimensions.
   ; This caused me some headache because I hadn't expected to see the dimensions
   ; shuffled around but they do ;-)
   ; set default (disallow use of offset, count, and stride)
   mapdims = -1L
   if n_elements(variables) gt 0 then begin
      w = where( StrUpCase(varnames) eq StrUpCase(variables[0]), wcnt )
      if wcnt eq 1 then begin   ; found it
          w = w[0]
          mapdims = ncdf_mapdims(varnames[w], vardimid.(w),  $
                                 count=count, offset=offset, stride=stride)
      endif
   endif
  
   ; initialize variable counter and result variable
   vcount = 0L
   result = { nothing : -1L }

   ; start building result structure with dimension variables
   ; unless NO_DIMENSIONS is set
   if not keyword_set(no_dimensions) then begin
      for i=0L,n_elements(dimnames)-1 do begin
          w = where(StrUpCase(varnames) eq StrUpCase(dimnames[i]), wcnt)
          if wcnt eq 1 then begin
             w = w[0]
             if keyword_set(verbose) then $
                 print,'Loading data for variable '+varnames[w]+' ...'
             ; decide whether simple read is feasible
             if mapdims[0] lt 0 then begin
                 NCDF_VARGET, id, w, data
             endif else begin
                 ; need to find out how to offset, count, and stride the data
                 ok = ncdf_TestDimensions(id, w, dims, mapdims, $
                      count=count, offset=offset, stride=stride,   $
                      thiscount=thiscount, thisoffset=thisoffset, thisstride=thisstride)
                 NCDF_VARGET,id, w, data, count=thiscount, offset=thisoffset, stride=thisstride
             endelse
             ; create structure or add to it
             if vcount eq 0L then $
                result = create_struct( Valid_Tagname(varnames[w]), data )  $
             else  $
                result = create_struct( result, Valid_Tagname(varnames[w]), data )  
             vcount = vcount + 1L
             if keyword_set(verbose) then $
                print,'OK. Data dimensions are '+string(size(data,/Dimensions),format='(12i6)')
          endif
      endfor
   endif


   ; see which variables were requested and go through them
   if n_elements(variables) gt 0 then dovars = variables
   if keyword_set(all) then dovars = varnames

   for i=0L,n_elements(dovars)-1 do begin
       ; check if variable has already been added
       validname = Valid_TagName(dovars[i])
       test = where(StrUpCase(Tag_Names(result)) eq StrUpCase(validname))
       if test[0] lt 0 then begin
          w = where(StrUpCase(varnames) eq StrUpCase(dovars[i]), wcnt)
          if wcnt eq 1 then begin
             w = w[0]
             if keyword_set(verbose) then $
                 print,'Loading data for variable '+varnames[w]+' ...'
             ; decide whether simple read is feasible
             if mapdims[0] lt 0 then begin
                 NCDF_VARGET, id, w, data
             endif else begin
                 ; need to find out how to offset, count, and stride the data
                 ok = ncdf_TestDimensions(id, w, dims, mapdims, $
                      count=count, offset=offset, stride=stride,   $
                      thiscount=thiscount, thisoffset=thisoffset, thisstride=thisstride)
                 NCDF_VARGET,id, w, data, count=thiscount, offset=thisoffset, stride=thisstride
             endelse
             ; create structure or add to it
             if vcount eq 0L then $
                result = create_struct( validname, data )  $
             else  $
                result = create_struct( result, validname, data )  
             vcount = vcount + 1L
             if keyword_set(verbose) then $
                print,'OK. Data dimensions are '+string(size(data,/Dimensions),format='(12i6)')
          endif
       endif
   endfor


   ; close netCDF file 
   NCDF_CLOSE,id

   ; extract the only requested variable if the no_struct keyword is set
   if keyword_set(no_struct) then begin
       nt = tag_names(result)
       test = strupcase(Valid_TagName(variables[0]))
       w = where(nt eq test,wcnt)
       if wcnt eq 1 then begin
           result = result.(w[0])
       endif else begin
           result = -999.
       endelse
   endif

   return
end
 
 
