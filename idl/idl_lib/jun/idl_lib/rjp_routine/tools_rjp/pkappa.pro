ikmm=20
a = grid(ikmm=ikmm,sgint=sgint,oned=1)

pint = 10.
psfc = 1000.
pz   = psfc - pint

sgint  = reverse(sgint)
dsig   = sgint(1:ikmm)-sgint(0:ikmm-1)
pressl = sgint*pz + pint


RUNIV  = 8314.3
AIRMW  = 28.97
RGAS   = RUNIV/AIRMW
CPD    = 1004.16
RKAP   = RGAS/CPD 

pkle  = pressl^rkap
pkz   = fltarr(ikmm)
pinv  = 1./(pz*(1.0+rkap))

 for ik = 0, ikmm-1 do begin
   dsiginv = 1./dsig(ik)
   pkz(ik) = (pressl(ik+1)*pkle(ik+1)-pressl(ik)*pkle(ik))*pinv*dsiginv
 end


press0 = 0.5*(pressl(1:ikmm)+pressl(0:ikmm-1))
test0  = press0^rkap

press1 = psfc*(pressl(1:ikmm)*pressl(0:ikmm-1)*1.e-6)^0.5
test1  = press1^rkap

 for ik = 0, ikmm-1 do print, ik, press0(ik), press1(ik)
 for ik = 0, ikmm-1 do print, ik, pkz(ik), test0(ik), test1(ik)

end
