function qnorm, x

da = fltarr(n_elements(x))
for d = 0, N_elements(da)-1 do da[d] = gauss_cvf(1.-x[d])

return, da

end