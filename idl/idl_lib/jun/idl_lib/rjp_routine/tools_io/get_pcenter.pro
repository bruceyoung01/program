 function get_pcenter, ps, modelinfo=modelinfo

   GridInfo = CTM_GRID( MOdelInfo )

   dim = size(ps)
   if dim[0] le 1 then begin
      ; calculate column pressure
      pedge = get_pedge(ps, modelinfo=modelinfo)
      press = ( pedge[1:*] + (shift(pedge,1))[1:*] ) * 0.5
      return, press
   end 

   if dim[0] eq 2 then begin
      ii = dim[1]
      jj = dim[2]

      p3 = fltarr(ii,jj,gridinfo.lmx)
      for j = 0, jj-1 do begin
      for i = 0, ii-1 do begin

         pedge = get_pedge(ps[i,j], modelinfo=modelinfo)
         press = ( pedge[1:*] + (shift(pedge,1))[1:*] ) * 0.5
         p3[i,j,*] = press
      end
      end
  
      return, p3
   end

 end
