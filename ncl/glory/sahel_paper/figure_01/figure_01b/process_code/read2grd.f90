program main 

integer num,i
integer,parameter :: num1=100000   
real np(num1),nl(num1),fire(num1),lon(num1),lat(num1)

   open (12,file='emission.txt')
     num=0
     do i=1,100000
     read(12,*,end=101) np(i), nl(i), fire(i),lat(i),lon(i)
     num=num+1 
     enddo
     num=num-1
101 close (12)

print*,num    
    open(13,file='emission_in.grd',form='unformatted',access='direct',recl=)
    do i=1,num    
      if ((lon(i).gt.80).and.(lon(i).lt.90).and.(lat(i).gt.0).and.(lat(i).lt.30)) then
      write(13,*) np(i),nl(i),fire(i),lon(i),lat(i)
      endif
    enddo

end
