; open the Temperature profile
readcol, 'July_T.txt', A, B, format='(I, I)'
A = float(A)
B = float(B)
ps_color, filename='July_T_difference.ps'
Conf = permutest(A, B, TD)
T0 = mean(A)-mean(B)
histoplot, TD, binsize=0.5, xtitle = 'ABS(TD)!C' + 'T0 = ' + strcompress(string(T0)), $
          title = 'frequency of permutation mean difference', $
          position=[0.1, 0.5, 0.9, 0.9]

histoplot, ABS(TD), binsize=0.5, xtitle = 'ABS(TD)!c' + 'ABS(T0) = ' $
          + strcompress(string(ABS(T0))) , $
          title = 'frequency of ABS(permutation mean difference)', $
          position=[0.1, 0.5, 0.9, 0.9]
device, /close 
end
