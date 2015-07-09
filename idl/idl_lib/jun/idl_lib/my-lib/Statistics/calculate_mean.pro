readcol, 'July_T.txt', Tmax, Tmean, format='I'
print, 'corrleation = ', correlate(Tmax, Tmean)
print, 'spearman correlation = ', R_CORRELATE(Tmax, Tmean)
END
