; $Id: koh_hno3.pro,v 1.50 2002/05/24 14:10:17 bmy v150 $



function koh_hno3,temp,press


; k(M,T)=k0(T)+k1(T)/(1+k1(T)/kc(T)[M])
; with ki(T)=Aiexp(-Ei/kbT) and
; A0=1.38 +/- 0.077 10e-14 cm3 s-1; E0/kb=-578 +/- 20 K
; A1=5.046 +/- 0.680 10e-17 cm3 s-1; E1/kb=-2067 +/- 29 K
; Ac=4.83 +/- 1.07 10e-33 cm3 s-1; Ec/kb = -906 +/- 40K
; I got this from Paul Wennberg who got it from Brown+Ravi.
; It came with a cautionary note that this is not for use in
; published manuscripts.

    M = 2.69e19*(273./temp)*(press/1013.25)

    A0 = 1.38e-14
    E0 = -578.
    A1 = 5.046e-17
    E1 = -2067.
    Ac = 4.83e-33
    Ec = -906.

    k0 = A0*exp(-E0/temp)
    k1 = A1*exp(-E1/temp)
    kc = Ac*exp(-Ec/temp)

    k = k0 + k1/( 1.+ k1/(kc*M) )

    return,k
end

