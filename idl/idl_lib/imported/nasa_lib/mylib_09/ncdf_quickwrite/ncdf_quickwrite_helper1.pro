;+
; @file_comments
;
;
; @categories
;
;
; @param NCVARSTRING
;
;
; @param NCDFSTRUCT
;
;
; @param STRUCTNAME
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
pro ncdf_quickwrite_helper1,ncvarstring,ncdfstruct,structname
;;
;; Parses the variable string so as to create the main structure.
;;
;;------------------------------------------------------------


on_error,2
compile_opt hidden
ncdfstruct={ncommands:-1}

;; split string, to extract IDL global attribute variable name
bits=strsplit(ncvarstring,'@',/extract)
case n_elements(bits) of
    1: begin
        ;; no attributes
        globattflag=0B
        globattnameidl=''
    end
    2: begin
        globattflag=1B
        globattnameidl=bits[1]
    end
    else: begin
        message,'Parse error: more than one "@" sign in '+ncvarstring, $
          /noname
    end
endcase
allvarspec=bits[0]


vars=strsplit(strcompress(allvarspec,/remove_all),';',/extract)
nvar=n_elements(vars)

varnames=strarr(nvar)
varnamesidl=strarr(nvar)

nvardims=intarr(nvar)
vardims=ptrarr(nvar)

varattflags=bytarr(nvar)
varattnamesidl=strarr(nvar)


;; at start, no dimensions known
ndim=0
dimnames=''
dimunlim=-1

for ivar=0,nvar-1 do begin
    
    varandattspec=vars[ivar]
    
    ;; split into IDL attribute variable name and full variable specification
    bits=strsplit(varandattspec,':',/extract)
    case n_elements(bits) of
        1: ;; no variable attributes
        2: begin
            varattflags[ivar]=1B
            varattnamesidl[ivar]=bits[1]
        end
        else: begin
            message,'Parse error: more than one ":" sign in '+varandattspec, $
              /noname
        end
    endcase
    fullvarspec=bits[0]
    
    
    ;; split full variable specification
    ;; into variable specification and IDL variable name
    ;; 
    bits=strsplit(fullvarspec,'=',/extract)
    case n_elements(bits) of
        1: varnameidl='' ;; fill this in later
        2: varnameidl=bits[1]
        else: begin
            message,'Parse error: more than one "=" sign in '+fullvarspec, $
              /noname
        end
    endcase
    
    varspec=bits[0]
    
    ;; split variable specification into name and dimension specification
    ;;    
    bits=strsplit(varspec,'[',/extract)
    varname=bits[0]
    case n_elements(bits) of
        1: begin
            ;; scalar
            nvardims[ivar]=0
        end
        2: begin
            dimspec=bits[1]
            ;; test for and strip trailing ']'
            len=strlen(dimspec)
            if strmid(dimspec,len-1,1) ne ']' then begin
                message,'Parse error: dimension specification "['+dimspec+ $
                  '" for variable "'+varname+'" should end with "]"', $
                  /noname
            endif
            dimspec=strmid(dimspec,0,len-1)
            
            if dimspec eq '' then begin
                ;; dimensions not specified - assume 1d array with 
                ;; same name for dimension as for variable
                vardimnames=[varname]
            endif else if dimspec eq '*' then begin
                ;; dimensions not specified but "*" given - as above,
                ;; again assume same name for dimension as for variable, 
                ;; but with * (parsed below as meaning UNLIMITED)
                vardimnames=['*'+varname]
            endif else begin
                vardimnames=strsplit(dimspec,',',/extract)
            endelse
            
            ;; now for each dimension name, see if it already exists,
            ;; and if not then add it as a new name
            
            nvardim=n_elements(vardimnames)
            nvardims[ivar]=nvardim
            
            thisvardims=intarr(nvardim)
            
            for i=0,nvardim-1 do begin
                
                dimname=vardimnames[i]
                
                ;; first see if dimname has leading "*"
                ;; if so, strip it, but record the fact that UNLIMITED
                ;; is wanted
                unlimited = (strmid(dimname,0,1) eq '*')
                if unlimited then dimname=strmid(dimname,1)
                
                if ndim gt 0 then begin
                    match=where(dimnames eq dimname,nmatch)
                    case nmatch of
                        0: begin
                            ;; no match - append to array
                            dimnames=[dimnames,dimname]
                            vardim=ndim
                            ndim=ndim+1
                        end
                        1: begin
                            ;; match found - point to it
                            vardim=match[0]
                        end
                        else: stop,'Duplicate match: BUG in NCDF_QUICK_HELPER1'
                    endcase
                endif else begin
                    ;; no dimensions known - this is the first
                    ndim=1
                    dimnames=[dimname]
                    vardim=0 ;; (for completeness)
                endelse
                
                if unlimited then begin
                    if (dimunlim ge 0  $
                        and dimunlim ne vardim) then begin
                        message,('NCDF dimensions "'+dimnames[dimunlim]+ $
                                 '" and "'+dimnames[vardim]+ $
                                 '" cannot both be of UNLIMITED size.'), $
                          /noname                        
                    endif
                    dimunlim=vardim
                endif
                
                thisvardims[i]=vardim
                
            endfor            
            vardims[ivar]=ptr_new(thisvardims)            
        end
        else: message,('Parse error: variable specification "'+varspec+ $
                       '" has stray "["'),/noname
    endcase
    
    if varnameidl eq '' then varnameidl=varname
    
    varnames[ivar]=varname
    varnamesidl[ivar]=varnameidl
endfor

;; ---------------------------------------------------
; now construct some commands, which, when executed at the top level, will
; put IDL variable size information into the structure.

commands=( structname+'.varsizes['+string(indgen(nvar))+ $
           ']=ptr_new(size('+varnamesidl+'))' )


; now some more commands, to tell the main level to copy the attributes
; into a heap location where the next helper routine will see them.

if globattflag then $
  commands=[commands,structname+'.globatts=ptr_new('+globattnameidl+')']

for ivar=0,nvar-1 do begin
    if varattflags(ivar) then begin
        commands=[commands, $
                  structname+'.varatts['+string(ivar)+ $
                  ']=ptr_new('+varattnamesidl[ivar]+')']
    endif      
endfor

;;
;; second argument comes back with a structure which contains all the
;; information, and also some variables to be used by next helper routine.
;;
ncdfstruct={ncommands:          n_elements(commands), $
            commands:           ptr_new(commands)   , $
            nvar:               nvar                , $
            varnames:           varnames            , $
            varids:             intarr(nvar)        , $
            nvardims:           nvardims            , $
            vardims:            vardims             , $
            varnamesidl:        varnamesidl         , $
            varsizes:           ptrarr(nvar)        , $
            varatts:            ptrarr(1+nvar)      , $
            varattflags:        varattflags         , $
            varattnamesidl:     varattnamesidl      , $
            globatts:           ptr_new()           , $
            globattflag:        globattflag         , $
            globattnameidl:     globattnameidl      , $
            ndim:               ndim                , $
            dimnames:           dimnames            , $
            dimids:             intarr(ndim>1)      , $
            dimunlim:           dimunlim            , $
            fileid:             0}

end
