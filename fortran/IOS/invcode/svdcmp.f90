!******************************************************************************
!  Given a matrix A, with logical dimensions M by N and physical dimensions MP by NP, this
!  routine computes its singular value decomposition, A = U.W.V'. The matrix U replaces 
!  A on output. The diagonal matrix of singular values W is output as a vector W. The matrix 
!  V (not the Transpose V') is output as V. M must be greater or equal to N; if it is smaller,
!  then A should be filled up to square with zero rows.
!******************************************************************************
!  Verified: working on 6 Feb 1998
!
! NOTES: 
! 1. When used to solve Linear Equations with n equations and n unknowns,
!     mp=np=m=n.
! 2. When finding inverses, n = soln and b = IdentityMatrix(n)
!
! Modifications to Original Program:
! 1. Equalties/Inequalities are replaced by Differences and compared with EPS
! 2. The Matrix U in U.W.V' is actually stored in "a"
!
! DEBUG:
! 1.  "IMPLICIT NONE" and "REAL(DBP)"
! 2.  Parameters might need to be larger
!******************************************************************************
SUBROUTINE SVDCMP(a,m,n,mp,np,w,v)


   implicit none
   
   INTEGER, PARAMETER :: nmax = 1000 !Maximum anticipated value of N
   REAL*8, parameter :: EPS = 3.0d-15  
   INTEGER :: m, n, mp, np, i ,j, l, k, its, nm, jj
   REAL*8 :: g, sscale, anorm, s, f, h, x, z, y, c

   REAL*8 :: A(mp,np), w(np), v(np,np), rv1(nmax)

   PRINT *, 'Precision chosen as ',eps

   if (m.lt.n) then
   	PRINT *, 'You must augment A with extra zero rows'
      call exit(10)
   ENDIF 

            !Householder Reduction to bidiagonal form
!(see Forsythe,Malcolm,Moler, "Computer Methods for Mathematical Computations"
   g=0.0d0
   sscale = 0.0d0
   anorm = 0.0d0
   do i = 1,n
      l = i + 1
      rv1(i) = sscale*g
      g = 0.0d0
      s = 0.0d0
      sscale = 0.0d0
      if (i.le.m) then
         do k = i,m
            sscale = sscale + dABS(a(k,i))
         end do       ! k loop
!         if (sscale.ne.0.0d0) then
			if ( dabs(sscale-0.0d0).gt.EPS ) then
            do k = i,m
               a(k,i) = a(k,i) / sscale
               s = s + a(k,i)*a(k,i)
            end do    ! k loop
            f = a(i,i)
            g = - SIGN(SQRT(s),f)
            h = f*g - s
            a(i,i) = f - g
            if (i.ne.n) then
               do j = l,n
                  s = 0.0d0
                  do k = i,m
                     s = s + a(k,i)*a(k,j)
                  end do      ! k loop
                  f = s / h
                  do k = i, m 
                     a(k,j) = a(k,j) + f*a(k,i)
                  end do   ! k loop
               end do      ! j loop
            end if
            do k = i, m 
               a(k,i) = sscale * a(k,i)
            end do         ! k loop
         end if
      end if

      w(i) = sscale * g
      g = 0.0d0
      s = 0.0d0
      sscale = 0.0d0
      if ((i.le.m).AND.(i.ne.n)) then
         do k = l, n
            sscale = sscale + dABS(a(i,k))
         end do         ! k loop
!         if (sscale.ne.0.0d0) then
			if ( dabs(sscale-0.0d0).gt.EPS ) then
            do k = l, n
               a(i,k) = a(i,k) /sscale
               s = s + a(i,k) * a(i,k)
            end do      ! k loop 
            f = a(i,l) 
            g = - SIGN(SQRT(s),f)
            h = f * g - s
            a(i,l) = f - g
            do k = l, n
               rv1(k) = a(i,k) / h
            end do      ! k loop
            if (i.ne.m) then
               do j = l, m 
                  s = 0.0d0
                  do k = l, n 
                     s = s + a(j,k)*a(i,k)
                  end do   ! k loop
                  do k = l, n 
                     a(j,k) = a(j,k) + s*rv1(k)
                  end do   ! k loop
               end do      ! j loop
            end if
				do k = l, n
               a(i,k) = sscale * a(i,k)
           	end do
         end if
      end if
      anorm = MAX(anorm, (dABS(w(i)) + dABS(rv1(i))))
   end do

! Accumulation of right-hand Transformations
   do i = n, 1, -1 
      if (i.lt.n) then
!         if (g.ne.0.0d0) then
			if ( dabs(g-0.0d0).gt.EPS ) then
            do j = l, n       ! Double division to avoid possible overflow
               v(j,i) = (a(i,j) / a(i,l)) / g
            end do      ! j loop
            do j = l, n
               s = 0.0d0
               do k = l, n
                  s = s + a(i,k)*v(k,j)
               end do   ! k loop
               do k = l, n
                  v(k,j) = v(k,j) + s * v(k,i)
               end do   ! k loop
           	end do      ! j loop
         end if
         do j = l, n 
            v(i,j) = 0.0d0
            v(j,i) = 0.0d0
         end do
      end if
      v(i,i) = 1.0d0
      g = rv1(i)
      l = i
   end do

! Accumulation of left-hand Transformations
   do i = n, 1, -1
      l = 1 + i
      g = w(i)
      if (i.lt.n) then
         do j = l, n
            a(i,j) = 0.0d0
         end do
      end if
!      if (g.ne.0.0d0) then
      if ( dabs(g-0.0d0).gt.EPS ) then
         g = 1.0d0 / g
         if (i.ne.n) then
            do j = l,n 
               s = 0.0d0
               do k = l, m
                  s = s + a(k,i)*a(k,j)
               end do   ! k loop
               f = (s/a(i,i)) * g
               do k = i, m 
                  a(k,j) = a(k,j) + f * a(k,i)
               end do   ! k loop
            end do      ! j loop
         end if
         do j = i, m 
            a(j,i) = a(j,i) * g
         end do         ! j loop
      else
         do j = i, m
            a(j,i) = 0.0d0
         end do         ! j loop
      end if
      a(i,i) = a(i,i) + 1.0d0
   end do               ! i loop

! Diagonalization of the bidigonal form
   do k = n, 1, -1                  !Loop over singular values
      do its = 1,30                 !Loop over allowed iterations
         do l = k, 1, -1            !Test for splitting
            nm = l - 1              ! Note that rv1(1) is always zero
!           if ( (dABS(rv1(l))+anorm) .eq. anorm ) GO TO 2
!          	if ( (dABS(w(nm))+anorm) .eq. anorm ) GO TO 1
            if ( dabs((dABS(rv1(l))+anorm) - anorm).lt.eps ) GO TO 2
          	if ( dabs((dABS(w(nm))+anorm) - anorm).lt.eps ) GO TO 1
         end do      !  l loop

1        c = 0.0d0                  ! Cancellation of rv1(l), if l>1 :
         s = 1.0d0
         do i = l, k
            f = s * rv1(i)
!            if ( (dABS(f)+anorm) .ne. anorm ) then
            if ( dabs( (dABS(f)+anorm) - anorm) .GT. eps ) then

               g = w(i)
               h = SQRT(f*f + g*g)
               w(i) = h
               h = 1.0d0 / h
               c = g * h
               s = -f * h
               do j = 1, m
                  y = a(j,nm)
                  z = a(j,i)
                  a(j,nm) = (y*c) + (z*s)
                  a(j,i) = -(y*s) + (z*c)
               end do   ! j loop
            end if
         end do         ! i loop
2        z = w(k) 
         if (l .eq. k) then         ! convergence
				if (z .lt. 0.0d0) then  ! Singular value is made non-negative
               w(k) = -z
               do j = 1,n
                  v(j,k) = -v(j,k)
               end do         ! j loop
	    		end if
            GO TO 3
         end if
         if (its.eq.30) then
         	PRINT*, 'No Convergence in 30 iterations'
            call exit(10)
         ENDIF
         x = w(l)          ! Shift from bottom 2-by-2 minor
         nm = k - 1
         y = w(nm)
         g = rv1(nm)
         h = rv1(k)
         f = ( (y-z)*(y+z) + (g-h)*(g+h) ) / ( 2.0d0*h*y)
         g = SQRT(f*f + 1.0d0)
         f = ( (x-z)*(x+z) + h*((y/(f+SIGN(g,f))) - h) ) / x

! Next   QR Transformation
         c = 1.0d0
         s = 1.0d0
         do j = l, nm
          	i = j + 1
            g = rv1(i)
            y = w(i)
            h = s*g
            g = c*g
            z = SQRT(f*f + h*h)
            rv1(j) = z
            c = f/z
            s = h/z
            f = (x*c) + (g*s)
            g = -(x*s) + (g*c)
            h = y*s
            y = y*c
            do jj = 1, n
               x = v(jj,j)
               z = v(jj,i)
               v(jj,j) = (x*c) + (z*s)
               v(jj,i) = -(x*s) + (z*c)
           	end do
            z = SQRT(f*f + h*h)
            w(j) = z
!            if (z.ne.0.0d0) then
            if (  dabs(z-0.0d0).gt.eps  ) then
               z = 1.0d0 / z
               c = f*z
               s = h*z
            end if
            f = (g*c) + (y*s)
            x = -(g*s) + (y*c)
            do jj = 1, m
               y = a(jj,j)
               z = a(jj,i)
               a(jj,j) = (y*c) + (z*s)
               a(jj,i) = -(y*s) + (z*c)
            end do
         end do         ! j loop
         rv1(l) = 0.0d0
         rv1(k) = f
         w(k) = x
      end do            ! its loop
3  continue
   end do               ! k loop

   return
END SUBROUTINE svdcmp


