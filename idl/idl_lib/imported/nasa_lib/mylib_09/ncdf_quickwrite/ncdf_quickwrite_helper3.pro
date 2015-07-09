;+
; @file_comments
;
;
; @categories
;
;
; @param S
; The string to be searched
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
pro ncdf_quickwrite_helper3,s
;;
;; Frees the variables in heap memory
;;
;;------------------------------------------------------------

on_error,2
compile_opt hidden

;; s is our ncdf structure

ptr_free,s.globatts
ptr_free,s.varatts
ptr_free,s.commands
ptr_free,s.vardims
ptr_free,s.varsizes
ptr_free,s.varatts

end
