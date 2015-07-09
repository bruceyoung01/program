function rnorm, n, mu, sd

if n_elements(n)  eq 0 then return, -1
if n_elements(mu) eq 0 then mu = 0.
if n_elements(sd) eq 0 then sd = 1.

val = randomn(seed, n)
val = val*sd + mu

return, val

end