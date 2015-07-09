
  ; solve problem 9.6

  LAMDA = [ [118.8, 0], [0, 2.60] ]
  EVECS = [ [0.7, -0.714], [0.714, 0.7] ]
  S = EVECS ## LAMDA ## transpose(EVECS)
  print, S


 ; problem 11.2
 LAMDA = [ [2.467, 0, 0], [0, 0.356, 0], [0, 0, 0.169] ]
 EVECS = [ [0.593, 0.332, 0.734], [0.552, -0.831, -0.069], [-0.587, -0.446, 0.676] ]
 S = EVECS ## LAMDA ## transpose(EVECS)
 PRINT, S


  END 

