
  ; EL year
  PEL = [26.1, 24.8, 26.4, 26.6, 26.8]
  PNEL = [24.5, 24.5, 24.1, 24.3, 24.9, 23.7, 23.5, $
          24.0, 24.1, 23.7, 24.3, 24.6, 24.8, 24.4, 25.2]
  n1 = n_elements(PEL)
  n2 = n_elements(PNEL)

  result = moment(PEL)
  meanPEL = result(0)
  PELSTD = sqrt(result(1))

  result = moment(PNEL)
  meanPNEL = result(0)
  PNELSTD = sqrt(result(1))

  deltau = meanPEL - meanPNEL
  deltas =  sqrt(PELSTD^2/n1 + PNELSTD^2/n2)
  xupper = 1.96 * deltas + (meanPEL - meanpNEL)
  xbottom = -1.96 * deltas + (meanPEL - meanpNEL)


 END

