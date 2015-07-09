; $Id: mwhere.pro,v 1.1.1.1 2006/02/23 18:09:37 rjp Exp $
;-------------------------------------------------------------
;+
; NAME:
;        MWHERE   (function)
;
; PURPOSE:
;        return array index position for occurence of data in array or scalar
;        matrix where
;
; CATEGORY:
;        tools
;
; CALLING SEQUENCE:
;        pos = mwhere(In, Out)
;
; INPUTS:
;        In  -> the data to be searched
;
;        Out -> the index to look for
;
;----------------------------------------------------------------

function mwhere,In,Out
 
 
   if (n_elements(In) eq 0) then return,-1
   if (n_elements(Out) eq 0) then return,-1

   Ind = Intarr(N_elements(In))
 
   ; Search for matches
   For D = 0, N_elements(In)-1 do $
   Ind[D] = where( Out eq In[D] )

   return, Ind

end
   
