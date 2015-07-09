;;
;; HELPER2
;; Constructs the commands which are actually needed to write the NetCDF file.
;;
;;-----------------------------------------------------------------------------

; this file contains:  STR, ncdf_quickwrite_typename, ncdf_quickwrite_helper2

compile_opt hidden

;------------------------------------------------------
;; _STR - like STRING, but with no whitespace.
;;
;; we use this function enough to give it a short name, but the underscore
;; is to make it unlikely to conflict with a user's function.
;+
; @file_comments
;
;
; @categories
;
;
; @param STRING
; String to be split. Contains text after in, out token on output.
; 
;
; @returns
;
;
; @restrictions
;
;
; @examples
; 
; 
; @history
;
;
; @version
; $Id$
;
;-
function _str,string
return,strcompress(string,/remove_all)
end

;------------------------------------------------------
;+
; @file_comments
;
;
; @categories
;
;
; @param NUM
;
;
; @param NAME{type=string}
; It is a string giving the name of the file to be opened. If NAME does not contain
; the separating character of directories ('/' under unix for example), the file
; will be looked for in the current directory.
; 
;
; @returns
;
;
; @restrictions
;
;
; @examples
; 
; 
; @history
;
;
; @version
; $Id$
;
;-
function ncdf_quickwrite_typename,num,name
on_error,2
;;
;; translate type number returned from "size" function into name usable by
;; ncdf routines
;;
;; if not valid type, throw an error, and use "name" in informational
;; message if set,
;;

case num of
    
    ;; usable types
    1: type='byte'
    2: type='short'
    3: type='long'
    4: type='float'
    5: type='double'
        
    ;; other types: set to something appropriate.
    7: type='char' ;; string
    12: type='long' ;; unsigned
    13: type='long' ;; unsigned long
    14: type='float' ;; 64-bit integer
    15: type='float' ;; 64-bit integer
    
    else: begin
        if num eq 0 then gripe='undefined' $
        else gripe='not of valid type for a NetCDF file.'
        
        if n_params() eq 1 then name='Data item'
        
        message,name+' is '+gripe,/noname
        
    end
    
endcase

return,type

end
;-----------------------------------------------------

;+
; @file_comments
;
;
; @categories
;
;
; @param NCFILENAME
;
;
; @param S
; The string to be searched
;
; @param SNAME
; 
;
; @returns
;
;
; @restrictions
;
;
; @examples
; 
; 
; @history
;
;
; @version
; $Id$
;
;-
pro ncdf_quickwrite_helper2,ncfilename,s,sname
;;
on_error,2
compile_opt hidden

;; NB main structure is called "s" - we use it so much that anything longer
;; could get tedious...


;; start with no commands - in fact "-1" is an error condition
s.ncommands=-1
;; free commands written by helper1 from heap
ptr_free,s.commands

dimsize=lonarr(s.ndim > 1) ;; (">1" stops error if all fields scalar)
types=strarr(s.nvar)
;;
;; first of all, work out dimension sizes.
;;

for ivar=0,s.nvar-1 do begin
    
    nvardim=s.nvardims[ivar]
    
    sizeinfo=*(s.varsizes[ivar])
    
    ntype=sizeinfo[sizeinfo[0]+1]
    
    types[ivar]= $
      ncdf_quickwrite_typename(ntype,'IDL expression "'+s.varnamesidl[ivar]+ $
                          '" (for NCDF variable "'+s.varnames[ivar]+')')
    
    if nvardim ne sizeinfo[0] then  $
      message,('NCDF variable "'+s.varnames[ivar]+'" is defined with '+ $
               _str(s.nvardims[ivar])+' dimension(s), '+ $
               'but corresponding ' + $
               'IDL expression "'+s.varnamesidl[ivar]+'" has '+ $
               _str(sizeinfo[0])+' dimension(s).'),/noname
    
    if nvardim ne 0 then begin ;; not scalar
        
        for ivardim=0,nvardim-1 do begin
            
            idim=(*(s.vardims[ivar]))[ivardim]
            wanted=sizeinfo[1+ivardim]
            previous=dimsize[idim]
            
            if previous ne 0 and previous ne wanted then $
              message,('NCDF dimension "'+s.dimnames[idim]+ $
                       '" is multiply used, but with conflicting sizes: '+ $
                       _str(previous)+' and '+_str(wanted)), $
              /noname
            
            dimsize[idim]=wanted
            
        endfor
        
    endif
        
endfor

;; ---- make commands to write the file... ----

;; to open the file
if n_elements(ncfilename) eq 0 then ncfilename='!idl.nc'
if strmid(ncfilename,0,1) eq '!' then begin
    ncfilename1=strmid(ncfilename,1)
    clobstr=',/clobber'
endif else begin
    ncfilename1=ncfilename
    clobstr=''
endelse
commands=[sname+'.fileid=ncdf_create('''+ncfilename1+''''+clobstr+')']

;; to do the dimensions
for idim=0,s.ndim-1 do begin
    
    if idim eq s.dimunlim then sizestr='/unlimited' $
    else sizestr=_str(dimsize[idim])
    
    commands=[commands, $
              sname+'.dimids['+_str(idim)+']=ncdf_dimdef('+sname+ $
              '.fileid,'''+s.dimnames[idim]+''','+sizestr+')']
endfor

;; to do the variables
for ivar=0,s.nvar-1 do begin
    
    if s.nvardims[ivar] eq 0 then dimstr='' $
    else dimstr=','+sname+'.dimids[['+strjoin(_str(*(s.vardims[ivar])),',')+']]'
    
    commands=[commands, $
              sname+'.varids['+_str(ivar)+']=ncdf_vardef('+sname+ $
              '.fileid,'''+s.varnames[ivar]+''''+ $
              dimstr+',/'+types[ivar]+')']
endfor

;; to do the global attributes

if s.globattflag then begin
    
    tags=tag_names(*s.globatts)
    ntags=n_elements(tags)
    
    for itag=0,ntags-1 do begin
        sizeinfo=size((*s.globatts).(itag))
        type=ncdf_quickwrite_typename(sizeinfo[sizeinfo[0]+1])
        
        commands=[commands, $
                  ('ncdf_attput,'+sname+'.fileid,/global,'''+ $
                   strlowcase(tags[itag])+ $
                   ''','+s.globattnameidl+'.'+tags[itag]+',/'+type)]
    endfor
    
endif      

;; to do the variable attributes

for ivar=0,s.nvar-1 do begin
    if s.varattflags[ivar] then begin
    
        tags=tag_names(*(s.varatts[ivar]))
        ntags=n_elements(tags)
    
        for itag=0,ntags-1 do begin
            sizeinfo=size((*(s.varatts[ivar])).(itag))
            type=ncdf_quickwrite_typename(sizeinfo[sizeinfo[0]+1])
            
            commands=[commands, $
                      ('ncdf_attput,'+sname+'.fileid,'+ $
                       sname+'.varids['+_str(ivar)+'],'''+ $
                       strlowcase(tags[itag])+''','+s.varattnamesidl[ivar]+'.'+ $
                       tags[itag]+',/'+type)]
        endfor
    endif      
endfor

;; to end the definition section
commands=[commands,'ncdf_control,'+sname+'.fileid,/endef']

;; to write the data
for ivar=0,s.nvar-1 do begin
    commands=[commands, $
              ('ncdf_varput,'+sname+'.fileid,'+sname+'.varids['+_str(ivar)+'],'+ $
               s.varnamesidl[ivar]) ]
endfor

;; close the file
commands=[commands,'ncdf_close,'+sname+'.fileid']


;; make commands available to main level
s.ncommands=n_elements(commands)
s.commands=ptr_new(commands)

end

