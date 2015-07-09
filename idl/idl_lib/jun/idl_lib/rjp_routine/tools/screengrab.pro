function ScreenGrabForGIF

   ; Get the color table vectors for WRITE_GIF
   TvLCT, R_Cur, G_Cur, B_Cur, /Get

   ;R_Cur[0] = 255  &  G_Cur[0] = 255  &  B_Cur[0] = 255
   ;R_Cur[1] =   0  &  G_Cur[1] =   0  &  B_Cur[1] =   0
   ;TVLct, R_Cur, G_Cur, B_Cur

   if ( !D.Name ne 'PS' ) then begin

      ; Get the visual depth
      Device, Get_Visual_Depth=VD

      ; True color device has visual depth greater than 8 
      if ( VD gt 8 ) then begin 


         ; read true color image and quantize to 256 bits for
         ; GIF output, since GIF can only hold 256 colors
         ; TRUE=3 specifies an image-interleaved array.
         Image = TvRd( 0, 0, !D.X_SIZE, !D.Y_SIZE, True=3 )

         ; Call COLOR_QUAN to quantize the true-color image
         ; to an image with COL
         ThisFrame = Color_Quan( Image, 3, R_Cur, G_Cur, B_Cur, Cube=6 )

      endif else begin
                                                                    
         ; Otherwise, Just
         ThisFrame = TvRd( 0, 0, !D.X_SIZE, !D.Y_SIZE )

      endelse
   endif

   ; Return
   return, ThisFrame
end

