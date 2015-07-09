function ppoints, n

    if(n_elements(n) gt 1) then n = n_elements(n)
    a = ifelse(n le 10, 3./8., 1./2.)

    if(n gt 0) then return, (findgen(n) + 1. - a[0])/(float(n) + 1.-2.*a[0]) $
    else return, -1

end

