; $Id: knmhc.pro,v 1.1.1.1 2003/10/22 18:09:38 bmy Exp $


function knmhc,T,p,names=names

FORWARD_FUNCTION ktroe

    names = [ 'CO', 'CH4', 'C2H2', 'C2H4', 'C2H6', 'C3H6', 'C3H8', 'i-BUT', $
              'CH3CL'  ]

    kkco   = [ 1.5e-13 ]     ; NOTE: p dependence

    kkch4  = [ 2.45e-12, 1775. ]  ; JPL97

    kkc2h2 = [ 5.5e-30, 0., 8.3e-13, -2. ]   ; JPL97 (Troe)

    kkc2h4 = [ 1.0e-28, 0.8, 8.8e-12, 0. ]   ; JPL97 (Troe)

    kkc2h6 = [ 8.7e-12, 1070. ]  ; JPL97

    kkc3h6 = [ 9.47e-12, -504. ]  ; from Atkinson 1994

    kkc3h8 = [ 1.0e-11, 660. ]  ; JPL97
  
    kkibut = [ 11.1e-18, -256. ]    ; from Atkinson 1994 (different formula !) 

    kkch3cl = [ 4.0e-12, 1400. ]    ; JPL97


    ; now compute rate constants

    kco = kkco(0) * (6.e-4*p + 1.)

    kch4 = kkch4(0) * exp(-kkch4(1)/T)

    kc2h2 = ktroe(T,p,kkc2h2(0),kkc2h2(1),kkc2h2(2),kkc2h2(3))

    kc2h4 = ktroe(T,p,kkc2h4(0),kkc2h4(1),kkc2h4(2),kkc2h4(3))

    kc2h6 = kkc2h6(0) * exp(-kkc2h6(1)/T)

    kc3h6 = kkc3h6(0) * exp(-kkc3h6(1)/T)

    kc3h8 = kkc3h8(0) * exp(-kkc3h8(1)/T)

    kibut = kkibut(0) * T * T * exp(-kkibut(1)/T)

    kch3cl = kkch3cl(0) * exp(-kkch3cl(1)/T)

    ; return everything as one big array
    n = n_elements(kco)

    if (n eq 1) then return, [kco,kch4,kc2h2,kc2h4,kc2h6,kc3h6,kc3h8, $
                              kibut,kch3cl]

    ; (else)
    res = fltarr(9,n)
    res(0,*) = kco
    res(1,*) = kch4
    res(2,*) = kc2h2
    res(3,*) = kc2h4
    res(4,*) = kc2h6
    res(5,*) = kc3h6
    res(6,*) = kc3h8
    res(7,*) = kibut
    res(8,*) = kch3cl

    return,res
end

