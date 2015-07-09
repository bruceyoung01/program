; ===============================================
; eqn_5.ncl
;
; Concepts illustrated:
;   - Drawing equations using function codes (complicated)
;   - Moving vertically in a text string using a function code 
;   - Moving horizontally in a text string using a function code 
;   - Drawing superscripts in a text string using a function code 
;   - Drawing subscripts in a text string using a function code 
;   - Changing the font of a text string  using a function code 
;   - Drawing text on the frame
;   - Increasing the font size of text
;   - Left-justifying text
;
; ===============================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;================================================
begin 
  wks   = gsn_open_wks ("ps", "eqn" )           ; open a workstation    
  txres               = True                      ; text mods desired
  txres@txJust        = "CenterLeft"              ; Default is "CenterCenter"

; not that a colon is the default function code, but since I have personally
; set the default code to be a tilda (~) in my .hluresfile, I manually 
; reset it here, since the colon makes for a cleaner example.
  txres@txFuncCode    = ":"                 
;****************************
; Equation 1
;***************************
; in the case of the square root, the line on top must be added separately.
; here we create super- and sub-scripts. S creates a superscript while
; B creates a subscript.  To return to the main vertical line, use the
; N function code.
  txres@txFontHeightF = 0.035 
  eqn=":V1::F8:l:F21: = :F18:u:F21:(g:S::F0:':N::F21:D:B:o:N:)/f :H-97::V38::F21:______"
  gsn_text_ndc(wks,eqn,.2,.6,txres)
;****************************
; Equation 2
;***************************
  eqn2 = ":V1::F8:y:B:i:N::V-2::F21: = - :V20:1:H-20::V-7:__:H-30::V-30::F8:b:H20::V20::Y300::X200::F34:r:Y::X::H-5::V-50::F21:0:H-5::V90::F21:x:V-45:curl:B:z:N::F8:t:B::F8:h:N::F21:dx + C"
  gsn_text_ndc(wks,eqn2,.2,.4,txres)

  draw(wks)
  frame(wks)     
end 
                      

