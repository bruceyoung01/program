function ifelse, expr, val1, val2

if n_elements(val1) eq 1 then f1 = replicate(val1, n_elements(expr)) else f1 = val1
if n_elements(val2) eq 1 then f2 = replicate(val2, n_elements(expr)) else f2 = val2

da = f1*expr + f2*(1.-expr)

return, da

end