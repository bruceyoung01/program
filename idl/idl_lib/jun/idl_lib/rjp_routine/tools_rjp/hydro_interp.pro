function hydro_interp, fd, pin=pin, pout=pout, undef=undef, Bdv=Bdv

;... I have not verified yet that
;... this routine can be used for both descending and ascending order.
;... For now it is working with ascending order for sure.
;... Assuming ascending order

; input field 
if n_elements(fd)    eq 0 then return, 0
; input pressure or sigma-p pressure
if n_elements(pin)   eq 0 then return, 0
if n_elements(pout)  eq 0 then return, 0
if n_elements(undef) eq 0 then undef = 'NaN'
if Pin[0] gt Pin[1]  then rev = 1L else rev = 0L

P0     = 1013.25
CPD    = 1004.16
CPV    = 1869.46                              
AIRMW  = 28.97
RUNIV  = 8314.3
RGAS   = RUNIV/AIRMW
RKAP   = RGAS/CPD 

nout   = n_elements(pout)
 Q     = fltarr(nout)

 If ( Rev eq 1L ) then begin
    Fd   = Reverse(Fd)
    Pin  = Reverse(Pin)
    Pout = Reverse(Pout)
 Endif

  imax = n_elements(fd)-1L
  imin = 0L
 
 for ic = 0, nout-1 do begin
   press = pout(ic)
   
   IF ( press lt Pin[0] ) then begin
      Q(ic) = undef
      if Keyword_set(Bdv) then Q(ic) = fd[0]
      goto, JUMP
   End  
   If ( press gt Pin[Imax] ) then begin
      Q(ic) = undef
      if Keyword_set(Bdv) then Q(ic) = fd(imax)
      goto, JUMP
   endif

  l_1 = locate(press,Pin)
  l   = l_1+1

  Pk    = (Pin/P0)^(RKAP)
  tPk   = (press/P0)^(RKAP)
  Q(ic) = fd(l_1)*(1.-(Pk(l_1)-tPk)/(Pk(l_1)-Pk(l))) + fd(l)*(Pk(l_1)-tPk)/(Pk(l_1)-Pk(l))

  JUMP: I = 0
 endfor

 If ( Rev eq 1L ) then begin
    Fd   = Reverse(Fd)
    Pin  = Reverse(Pin)
    Pout = Reverse(Pout)
    Q    = Reverse(Q)
 Endif

 return, Q
end

