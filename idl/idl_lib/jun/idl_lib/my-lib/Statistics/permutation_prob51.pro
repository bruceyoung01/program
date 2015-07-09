  ; EL year
  PEL = [26.1, 24.8, 26.4, 26.6, 26.8]
  PNEL = [24.5, 24.5, 24.1, 24.3, 24.9, 23.7, 23.5, $
          24.0, 24.1, 23.7, 24.3, 24.6, 24.8, 24.4, 25.2]
  ps_color, filename='July_T_difference.ps'
  Conf = permutest(PEL, PNEL, PD)
  P0 = mean(PEL)-mean(PNEL)
  ps_color, filename='Precip_EL_NEL.ps'
  histoplot, PD, binsize=0.25, xtitle = 'P!C' + 'P0 = ' + strcompress(string(P0)), $
          title = 'frequency of permutation mean difference', $
          position=[0.1, 0.5, 0.9, 0.9]

  histoplot, ABS(PD), binsize=0.25, xtitle = 'P!C' + 'ABS(P0) = ' + $
          strcompress(string(ABS(P0))), $
          title = 'the distribution means are the same !cat the confidence level of' + $
          strcompress(string(Conf*100., format='(f7.2)')) + '%' , $
          position=[0.1, 0.5, 0.9, 0.9]

  device, /close
  end
