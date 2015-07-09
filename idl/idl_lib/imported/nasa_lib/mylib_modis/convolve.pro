function convolve, image, psf, FT_PSF=psf_FT, FT_IMAGE=imFT, NO_FT=noft, $
                        CORRELATE=correlate, AUTO_CORRELATION=auto
;+
; NAME:
;       CONVOLVE
; PURPOSE:
;       Convolution of an image with a Point Spread Function (PSF)
; EXPLANATION:
;       The default is to compute the convolution using a product of 
;       Fourier transforms (for speed).
;
;       The image is padded with zeros so that a large PSF does not
;       overlap one edge of the image with the opposite edge of the image.
;
; CALLING SEQUENCE:
;
;       imconv = convolve( image1, psf, FT_PSF = psf_FT )
;  or:
;       correl = convolve( image1, image2, /CORREL )
;  or:
;       correl = convolve( image, /AUTO )
;
; INPUTS:
;       image = 2-D array (matrix) to be convolved with psf
;       psf = the Point Spread Function, (size < or = to size of image).
;
;       The PSF *must* be symmetric about the point
;       FLOOR((n_elements-1)/2), where n_elements is the number of
;       elements in each dimension.  For Gaussian PSFs, the maximum
;       of the PSF must occur in this pixel (otherwise the convolution
;       will shift everything in the image).
;
; OPTIONAL INPUT KEYWORDS:
;
;       FT_PSF = passes out/in the Fourier transform of the PSF,
;               (so that it can be re-used the next time function is called).
;       FT_IMAGE = passes out/in the Fourier transform of image.
;
;       /CORRELATE uses the conjugate of the Fourier transform of PSF,
;               to compute the cross-correlation of image and PSF,
;               (equivalent to IDL function convol() with NO rotation of PSF)
;
;       /AUTO_CORR computes the auto-correlation function of image using FFT.
;
;       /NO_FT overrides the use of FFT, using IDL function convol() instead.
;               (then PSF is rotated by 180 degrees to give same result)
; METHOD:
;       When using FFT, PSF is centered & expanded to size of image.
; HISTORY:
;       written, Frank Varosi, NASA/GSFC 1992.
;       Appropriate precision type for result depending on input image
;                               Markus Hundertmark February 2006
;       Fix the bug causing the recomputation of FFT(psf) and/or FFT(image)
;                               Sergey Koposov     December 2006
;       Fix the centering bug
;                               Kyle Penner        October 2009
;-
        compile_opt idl2
        sp = size( psf_FT,/str )  &  sif = size( imFT, /str )
        sim = size( image )  &  sc = floor((sim-1)/2) & npix = n_elements(image)*4.

        ; the spooky factor of 4 in npix is because we're going to pad the image
        ; with zeros

        if (sim[0] NE 2) OR keyword_set( noft ) then begin
                if keyword_set( auto ) then begin
                        message,"auto-correlation only for images with FFT",/INF
                        return, image
                  endif else if keyword_set( correlate ) then $
                                return, convol( image, psf ) $
                        else    return, convol( image, rotate( psf, 2 ) )
           endif

        if (sif.N_dimensions NE 2) OR ((sif.type NE 6) AND (sif.type NE 9)) OR $
           (sif.dimensions[0] NE sim[1]) OR (sif.dimensions[1] NE sim[2]) then begin

            ; here is where we make an array with twice the dimensions of image and
            ; pad with zeros -- thanks to Daniel Eisenstein for this fix

            image_big = dblarr(sim[1]*2,sim[2]*2)
            image_big[0:sim[1]-1,0:sim[2]-1] = image
            imFT = FFT( image_big,-1 )
            npix = n_elements(image_big)

        endif


        if keyword_set( auto ) then begin
         intermed = shift( npix*real_part(FFT( imFT*conj( imFT ),1 )), sc[1],sc[2] )
         return, intermed[0:sim[1]-1,0:sim[2]-1]
     endif


        if (sp.N_dimensions NE 2) OR ((sp.type NE 6) AND (sp.type NE 9)) OR $
           (sp.dimensions[0] NE sim[1]) OR (sp.dimensions[1] NE sim[2]) then begin
                sp = size( psf )
                if (sp[0] NE 2) then begin
                        message,"must supply PSF matrix (2nd arg.)",/INFO
                        return, image
                   endif
                ; this obfuscated line determines the offset between the center of the
                ; image and the center of the PSF
                Loc = ( sc - floor((sp-1)/2) )  > 0

                psf_image = dblarr(sim[1]*2,sim[2]*2)
                psf_image[Loc[1]:Loc[1]+sp[1]-1, Loc[2]:Loc[2]+sp[2]-1] = psf
                psf_FT = FFT(psf_image, -1)
           endif

        if keyword_set( correlate ) then begin
                conv = npix * real_part(FFT( imFT * conj( psf_FT ), 1 ))
                conv = shift(conv, sc[1], sc[2])
            endif else begin
                conv = npix * real_part(FFT( imFT * psf_FT, 1 )) 
                conv = shift(conv, -sc[1], -sc[2])

            endelse

        
return, conv[0:sim[1]-1,0:sim[2]-1]

end
