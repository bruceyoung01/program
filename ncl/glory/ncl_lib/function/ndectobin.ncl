;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FUNCTION : DECTOBIN                                                ;
; PURPOSE OF THIS PROGRAM :                                          ;
; CONVERT DECIMAL SYSTEM TO BINARY FOR ONE ARRAY                     ;
; BRUCE (11/19/2011 18:49)                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function ndectobin(dec_num_array:integer)
local dq, dim, ndim, i, j, k, l, cmd, dec_num_array1
begin 

  bv3= "missingvalue"
; DOUBLE QUOTE CHARACTER
  dq = str_get_dq()

; GET THE DIMENSION SIZE OF ARRAY dec_num_array
  dim  = dimsizes(dec_num_array)
  dec_num_array1 = new((/dim/), string, bv3)
  ndim = dimsizes(dim)
  
; JUDGE THE # OF DIMENSION, THEN USE DIFFERENT LOOP
  if (ndim .eq. 1) then
   do i = 0, dim(0) - 1
;---UNIX command that converts decimal to binary
    if (.not.ismissing(dec_num_array(i)) .and. \
         dec_num_array(i) .gt. 0) then
    cmd = "echo " + dq + "ibase=10;obase=2;" + \
           dq + dec_num_array(i) + " | bc "

;---Execute UNIX command and return an integer
    dec_num_array1(i) = tostring(systemfunc(cmd))
    else
    dec_num_array1(i) = bv3
    end if
   end do
  end if

  if (ndim .eq. 2) then
   do i = 0, dim(0) - 1
    do j = 0, dim(1) - 1
;---UNIX command that converts decimal to binary
    if (dec_num_array(i, j) .gt. 0) then
     cmd = "echo " + dq + "ibase=10;obase=2;" + \
            dq + dec_num_array(i, j) + " | bc "

;---Execute UNIX command and return an integer
     dec_num_array1(i, j) = tostring(systemfunc(cmd))
    else
    dec_num_array1(i, j) = bv3
    end if
    end do
   end do
  end if

  if (ndim .eq. 3) then
   do i = 0, dim(0) - 1
    do j = 0, dim(1) - 1
     do k = 0, dim(2) - 1
;---UNIX command that converts decimal to binary
     if (dec_num_array(i, j, k) .gt. 0) then
      cmd = "echo " + dq + "ibase=10;obase=2;" + \
             dq + dec_num_array(i, j, k) + " | bc "

;---Execute UNIX command and return an integer
      dec_num_array1(i, j, k) = tostring(systemfunc(cmd))
     else
     dec_num_array1(i, j, k) = bv3
     end if
     end do
    end do
   end do
  end if

  if (ndim .eq. 4) then
   do i = 0, dim(0) - 1
    do j = 0, dim(1) - 1
     do k = 0, dim(2) - 1
      do l = 0, dim(3) - 1
;---UNIX command that converts decimal to binary
       if (dec_num_array(i, j, k, l) .gt. 0) then
       cmd = "echo " + dq + "ibase=10;obase=2;" + \
              dq + dec_num_array(i, j, k, l) + " | bc "

;---Execute UNIX command and return an integer
       dec_num_array1(i, j, k, l) = tostring(systemfunc(cmd))
       else
       dec_num_array1(i, j, k, l) = bv3
       end if
      end do
     end do
    end do
   end do
  end if
  return(dec_num_array1)
end
