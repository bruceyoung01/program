 pro rjp_ctable, R, G, B


 N = 60L
 DC = 255./float(N-1L)

 As_A = Fix(findgen(N)*DC)
 Ds_A = Fix(reverse(Findgen(N))*DC)

 C0 = Replicate(0L, N)
 CM = Replicate(255L, N)

red  =[  255,  0,255,  0,  0,255,255,  0,255,127,127,0,90,150,188,220,240,255]
green=[  255,  0,  0,255,  0,255,  0,255,127,255,127,0,90,150,188,220,240,255]
blue =[  255,  0,  0,  0,255,  0,255,255,127,127,255,0,90,150,188,220,240,255]

      R = FltArr( 256 ) + 255
      G = FltArr( 256 ) + 255
      B = FltArr( 256 ) + 255
      M        = N_Elements( Red )
      R[0:M-1] = Red
      G[0:M-1] = Green
      B[0:M-1] = Blue

 ; first regime

 R[18:77] = C0
 G[18:77] = As_A
 B[18:77] = CM

 ; second regime
 R[78:137] = As_a
 G[78:137] = CM
 B[78:137] = Ds_a

 ; third regime
 R[138:197] = CM
 G[138:197] = Ds_a
 B[138:197] = C0

 ; last regime
 R[198:255] = Ds_a[0:57]
 G[198:255] = C0[0:57]
 B[198:255] = [As_A[0:28]/2,Ds_A[31:59]/2]


 end


