np = 135 
nl = 203 
AOD = intarr(np, nl)
openr, 1, 'MOD04_L2.A2005223.1435.051.2010299212039.Optical_Depth_Land_And_Ocean'
readu, 1, AOD
close, 1

QAC = bytarr(5, np, nl)
openr, 1, 'MOD04_L2.A2005223.1435.051.2010299212039.Quality_Assurance_Land'
readu, 1, QAC 
close, 1

end
