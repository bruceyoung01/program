; $Id: create3dfstru.pro,v 1.1.1.1 2003/10/22 18:06:02 bmy Exp $

function create3dfstru,elements


     ; create a sample of the extended fileinfo structure

     stru = { f3dstru,           $     ; name of structure
              filename:'',       $     ; name of file
              ilun:0L,           $     ; logical file unit
              filetype:0,        $     ; 0=ASCII, 1,2=binary, 3=GEOS restart
              status:1,          $     ; indicates error condition
              toptitle:'',       $     ; first header line
              modelinfo:ctm_type('DUMMY'),  $     ; model type information
              gridinfo:ptr_new()           } ; grid information 


     ; if elements not provided or eq 1, return the sample, else replicate
     if (n_elements(elements) eq 0) then elements = 1

     if (elements eq 1) then return,stru

     struarr = replicate(stru,elements)
     return,struarr

end
 
