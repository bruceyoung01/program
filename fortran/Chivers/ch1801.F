      program ch1801
      implicit none
      integer , pointer :: a=>null(),b=>null()
      integer , target :: c
      integer :: d
      c= 1
      a => c
      PRINT *, "DEBUG01 = ", a
      c= 2
      PRINT *, "DEBUG02 = ", a
      b => c
      PRINT *, "DEBUG03 = ", b
      d=a+ b
      print *,a,b,c,d
      end program ch1801
