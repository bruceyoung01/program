!
! This program reads the RAMS output.
!

module read_rams_module
contains
! Function
subroutine   read_rams(filename, varname, timearry, vararry, heightarry, &
             nt, nz0, np, nl, nzmax )

! parmater
      implicit none
      integer, parameter:: maxl = 1000, maxlay=100000   !time *  layers, 20* 1000

!Input:
!      
      character*150 :: filename, &    ! input filename
                       varname        ! var name, AOT, smoke, etc.

!      integer:: np=48, nl=48, nt, nz0=1
       integer:: np, nl, nt, nz0, nzmax

!output
      real, pointer::   timearry(:, :), &  ! time array
                   vararry(:, :, :, :), &  ! var array
		heightarry(:,:)   

!internal
       integer :: i, j, k, kk, nz
       real :: tmptime, tmph
       character*150 :: nouse1, nouse2
       real, allocatable:: tmpvar(:,:), timev(:,:), heightv(:,:), aotv(:,:,:,:)

!allocate
       allocate(tmpvar(np,nl))
       allocate(timev(maxl, nz0))
       allocate(heightv(maxl, nz0))
       allocate(aotv(np, nl, maxl, nz0)) 

! specify file name
!      filename = '../../data/parallel_offline/grid1/SW.dmp' 
!      varname = 'RSHORT'
! initia other values
      nt = 1
      nz = 1
      print*, 'varname = ', varname
      print*, 'filename = ', filename 

! start

       if ( varname .eq. 'LAT' .or. varname .eq. 'LON' .or. &
            varname .eq. 'PBL' .or. varname .eq. 'TOPO' .or. &
	    varname .eq. 'RSHORT' .or. varname .eq. 'ALBEDO' .or. &
	    varname .eq. 'CLDFRAC')  nzmax = 1

       open(2, file =filename, status='old')
       do  i = 1, MaxLay
         if ( varname .eq. 'MASS') then 
	   read(2, '(25x, f11.2, f10.0)', end=100) tmph, tmptime
	   
         else if ( varname .eq. 'AOT') then
	   read(2, '(19x, f11.2, f10.0)', end=100) tmph, tmptime 
	   
         else if ( varname .eq. 'RH') then
	   read(2, '(35x, f11.2, f11.0)', end=100) tmph, tmptime  
         
	 else if ( varname .eq. 'GEO') then
	   read(2, '(35x, f7.0, f11.0)', end=100) tmph, tmptime  
         
	 else if ( varname .eq. 'TEMP') then
	   read(2, '(27x, f11.2, f10.0)', end=100) tmph, tmptime  
         
	 else if ( varname .eq. 'PBL') then
	   read(2, '(26x, f11.2, f10.2)', end=100) tmph, tmptime  
	 
	 else if ( varname .eq. 'SW') then
	   read(2, '(25x, f11.2, f10.2)', end=100) tmph, tmptime  
         
	 else if ( varname .eq. 'RLONG') then
	   read(2, '(25x, f11.2, f11.0)', end=100) tmph, tmptime  
	 
	 else if ( varname .eq. 'ALBEDO') then
	   read(2, '(23x, f11.2, f11.0)', end=100) tmph, tmptime  
	 
	 else if ( varname .eq. 'LAT') then
	   read(2, '(26x, f11.2, f10.2)', end=100) tmph, tmptime  
	 
	 else if ( varname .eq. 'LON') then
	   read(2, '(27x, f11.2, f10.2)', end=100) tmph, tmptime  
	 
	 else if ( varname .eq. 'TOPO') then
	   read(2, '(20x, f11.2, f10.2)', end=100) tmph, tmptime  
	 
	 else if ( varname .eq. 'CLDFRC') then
	   read(2, '(30x, f11.2, f10.2)', end=100) tmph, tmptime  
	 
	 else if ( varname .eq. 'HRT') then
	   read(2, '(31x, f11.2, f10.0)', end=100) tmph, tmptime  
	 
	 else
	   STOP 'No correct varname'
	 endif

!	 print*, 'tmph = ', tmph, 'tmptime = ', tmptime
	 
!continue to read
         read(2, *, end=100) tmpvar
!	 print*, 'tmpvar = ', tmpvar


	 if (nz .le. nz0) then 
	    timev(nt, nz) = tmptime
	    heightv(nt, nz) = tmph
	    aotv(1:np, 1:nl, nt, nz) = tmpvar(1:np, 1:nl)
	 endif
	 
! start next time
         nz = nz + 1
         if ( mod(nz,  nzmax+1) .eq. 0 ) then 
	   nt = nt +1
	   nz = 1
	 endif
!	 print*, 'nt = ', nt 
       enddo
  100  continue
       close(2)
        
! reduce nt by  1, nt is increased by 1 in last loop 
        nt = nt -1
     
!     print*, 'read is over'
      if ( associated(timearry)) deallocate(timearry)
      if ( associated(heightarry)) deallocate(heightarry)

      allocate(timearry (nt, nz0))
      allocate(heightarry (nt, nz0))
      allocate(vararry (np, nl, nt, nz0))
   
! transfer arrays
      timearry(1:nt, 1:nz0) = timev(1:nt, 1:nz0)
      heightarry(1:nt, 1:nz0) = heightv(1:nt, 1:nz0)
      vararry(1:np, 1:nl, 1:nt, 1:nz0) = aotv(1:np, 1:nl, 1:nt, 1:nz0)

! dellocate
      deallocate(timev)
      deallocate(heightv)
      deallocate(aotv)

! test values at last time
!      print*, 'last time is ', timearry(nt, 1)

    print*, 'read ', trim(adjustl(varname)), ' is over',  ' nz0= ', nz0, 'nt = ', nt, 'nzmax = ', nzmax
   return
end subroutine read_rams

!
! subroutine for outputing data 
!
     subroutine outputF (filename, np, nl, nz, vararry)
     implicit none
!input
     character*150 filename      !input file name
     integer:: np, nl, nz        !dimension of input arry
     real, dimension(np,nl, nz):: vararry

! start
     open(2, file=filename, access='direct', recl=np*nl*nz*4)
     write(2,rec=1) vararry
     close(2)
     print* , 'file size = ', np * nl * nz * 4 
     return     
end subroutine outputF

end module read_rams_module

      
