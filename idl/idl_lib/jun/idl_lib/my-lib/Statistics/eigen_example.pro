;
; code to illustrate how to use IDL to compute eigenvalues.
X = [2, 4, 3, 5, 4, 5, 7, 6]
Y = [2, 1, 4, 2, 7, 5, 5, 8]

A = transpose([ [X], [Y] ])
print, 'A = '
print, A

m = [ [ mean(a(0,*))], [mean(a(1,*))] ]
print, 'mean = '
print, m

Xanomaly = X-mean(X)
Yanomaly = y-mean(Y)
Annomaly = transpose( [ [Xanomaly], [Yanomaly]] )

cov =  correlate(a, /covariance)
print, 'covariance '
print, cov

eigenvalues = eigenql(cov, eigenvectors = evecs)
print, 'eigenvalues '
print, eigenvalues

; note in IDL, the ith row in returned evecs
; corresponding to the ith eigenvectors, while
; in the text, we like to the jth column represents 
; jth eigenvectors, so always transform before we use it.
print, 'eigenvectors '
evecs = transpose(evecs)

; get the new data after the transformation
; not what is transformed is the anomaly, not the data itself
newA = Annomaly ## evecs   
print, 'new data after transformation'
print, newA

; display results
Device, Decomposed=0
set_plot, 'x'
!p.background=255
!p.charsize=2
window, 1

; plot data points
plot, [1, 7], [1, 9], xtitle = 'X', ytitle = 'Y', $
color=1, xrange = [-1, 12], yrange=[-1, 12], xstyle=1, $
ystyle=1, /nodata, position=[0.1, 0.2, 0.6, 0.9]
plots, A(0, *), A(1, *), psym=4, color=1, symsize=2
img = tvrd()

; plot the lines for the transformation matrix
; [x', y'] =  [e1, e2] * tranpose(e) 
; x = x'+xmean, y = y' +ymean
; here, [x, y] means the first  column is about x, and
; second column is on y
; define new axis in new coordinate
; use np = 11 points to respresent a line
np = 11 
e1 = transpose([ [findgen(np)-np/2], [fltarr(np)]] )
; re-transpform the new axis into old coordinate
e1inOld = e1 ## transpose(evecs) 

; plot axis after rotation
oplot, transpose(e1inOld(0,*))+m(0), transpose(e1inOld(1, *))+m(1), $
       color=1, linestyle=1

;define direction of e2 
arrow, e1inOld(0,np-2)+m(0), e1inOld(1,np-2) +m(1), $ 
       e1inOld(0,np-1)+m(0), e1inOld(1,np-1) +m(1), $
       hsize=10, /data, color=1
   
xyouts, e1inOld(0,np-1)+m(0), e1inOld(1,np-1) +m(1), 'e1',$
        color=1 

; define new yaxis in new coordinate
e2 = transpose ([ [fltarr(np)], [findgen(np)-np/2]] )

; re-transpform the new axis into old coordinate
e2inOld = e2  ## transpose(evecs)

; plot line for y after rotation
oplot, transpose(e2inOld(0,*))+m(0) , transpose(e2inOld(1, *))+m(1), $
      color=1, linestyle=2

;define direction of e2 
arrow, e2inOld(0,np-2)+m(0), e2inOld(1,np-2) +m(1), $ 
       e2inOld(0,np-1)+m(0), e2inOld(1,np-1) +m(1), $
       hsize=10, /data, color=1
xyouts, e2inOld(0,np-1)+m(0), e2inOld(1,np-1) +m(1), 'e2', $
        color=1 
write_png, 'eigen_img.png', img
end


