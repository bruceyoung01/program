; JaeSub Hong, 2003-2005, version 1.7
; Please report any problem or suggestion at jaesub@head.cfa.harvard.edu
; 
; Calculate quantiles from a distribution
; Refer to 
;	J. Hong, E.M. Schlegel & J.E. Grindlay, 
;	2004 ApJ 614 p508 and references therein
; 
; required routines : interpol.pro and ibeta.pro
;		they are noramlly included in the standard idl distribution
;
; usage
;	qt = quantile(frac, src, range=range,  $
;		bkg, ratio=ratio, err_Ex=err_Ex)
; examples
;	range=[0.3,8.0]
;	src=randomu(seed, 100) * (range[1]-range[0]) +range[0]
;	qt = quantile(frac, src, range=range, err_Ex=err_Ex)
;
;	bkg_on = randomu(seed, 20) * (range[1]-range[0]) +range[0]
;	bkg = randomu(seed, 100) * (range[1]-range[0]) +range[0]
;	src = [src,bkg_on] ; src and bkg photons in the src region
;	qt = quantile(frac, src, range=range, bkg, ratio=0.2, err_Ex=err_Ex)
;
; required input:
;	frac: list of quantile fractions 
;		default: 0.25,0.33,0.5,0.67,0.75
;	src : value lists in the source region 
;		(e.g. energies of photons in the source region)
;	range :  the full range of values
; required input for bkgnd subtraction:
;	bkg : value lists in the bkgnd region 
;		(e.g. energies of photons in the bkgnd region)
;		should be sorted in a increasing order
;	ratio : ration of the source to bkgnd region
; optional input
;	nip : number of interplation points for bkgnd subtraction
;		default 2000
;	/nofixerror : unless requested, the following correction 
;		for error estimation is automatically applied
;		1. when the error estimation fails, it normally returns
;			-1 for the error, but we can set the error to 
;			the whole range, which is reasonable.
;		2. when net<100, the error could be overestimated 
;			as much as 20-30% (See Fig.9 in Hong et al 2004)
;			a relatively moderate correction
;				x1./(1.+0.5/net) 
;			is applied to correct this.
;		3. correction for error due to bkgnd is applied 
;			sqrt(1+Nbkg/Nsrc) = sqrt(1.+(src-net)/net) (See Fig.9)
;		4. Error for QDy is likely overestimated
;			due to correlation of Q25/Q75, 
;			so x0.8 applied to compensate this 
; 		Refer to Hong et al 2004
;	/nosort: src and bkg will be sorted in ascending order, but
;		they are already sorted, you can skip the sorting procedure
;
; return value and optional output 
;	return value : quantiles Ex%
;	err_Ex : error estimation of Ex%
;	Qx : quantiles Qx = (Ex% - Elo) / (Eup - Elo)
;	err_Qx : error restimation of Qx
;	QDx : QCCD x value
;	QDy : QCCD y value
;	err_QDx : error of QDx
;	err_QDy : error of QDy
;
; required routines
; 	interpol.pro
;	ibeta.pro : use version 1.21 or higher 
; to-do
; 	include Harrell-Davis tech
;	routines to generate grid pattern 

;------------------------------------------------------------------------
function qt_os, frac, values, range=range
; quantile estimation by order statistics

n_values=n_elements(values)
i = findgen(n_values)
ifrac = (i*2.+1.)/2./n_values

; force the boundary condition
values_ = [range[0],values,range[1]]
ifrac_ = [0.0,ifrac,1.0]
ans =interpol(values_,ifrac_, frac)
return, ans
end

function qt_err_mj, frac, values, range=range
; Error estimation by Maritz-Jarrett method

n=n_elements(values)
n_frac=n_elements(frac)

m=frac*n+0.5
a = m-1.
b = n-m

; ibeta is computational demanding in idl
i_src = findgen(n+1.)/n
ans=frac*0.0
for i=0,n_frac-1 do begin
	if (a[i] gt 0.0) and (b[i] gt 0.0) then begin
		beta = ibeta(a[i],b[i],i_src) 
	;	print,i,beta
		w=beta[1:*]-beta[0:n-1]
		c = w*values
		c1 = total(c)
		c2 = total(c*values)
		c0 = c2-c1^2
		if c0 ge 0.0 then ans[i]=sqrt(c0) $
		else ans[i]=-1.
	endif else begin
		ans[i]=-1.
	endelse
endfor

return,ans
end

function qt_fix_err, Ex, error, n_net, n_src, range=range

maxerror = (range[1]-Ex)>(Ex-range[0])

w=where(error gt 0.0 and error lt maxerror,cw)
if cw gt 0 then $
	error[w]= error[w] / (1.+0.5/(n_net>1.)) $
		* sqrt(1.+(n_src-n_net)/n_net)

w=where(error le 0.0,cw) 
if cw gt 0 then error[w] = maxerror[w]
w=where(error ge maxerror,cw) 
if cw gt 0 then error[w] = maxerror[w]
return, error
end

;------------------------------------------------------------------------
function qt_simple, frac, values, range=range, $
	err_Ex=err_Ex
ans=qt_os(frac, values, range=range)
err_Ex=qt_err_mj(frac,values,range=range)
return, ans
end

pro qt_qccd, range, $
	frac=frac, $
	Ex=Ex, err_Ex=err_Ex, $
	Qx=Qx, err_Qx=err_Qx, $
	QDx=QDx, QDy=QDy, $
	err_QDx=err_QDx, err_QDy=err_QDy, $
	nofixerror=nofixerror
	
	rl = range[1]-range[0]
	Qx = (Ex-range[0])/rl
	err_Qx = err_Ex/rl

	QDx = alog10(Qx[1]/(1.-Qx[1]))
	m_l = Qx[1] - err_Qx[1]
	m_u = Qx[1] + err_Qx[1]

	bigN = 1.e3
	; big number for divergence, is this big enough or too big

	err_QDx_l = bigN
	err_QDx_u = bigN
	if (err_Qx[1] gt 0.0) then begin
		if (m_l gt 0.0) then $
			err_QDx_l = QDx-alog10(m_l/(1.-m_l))
		if (m_u lt 1.0) then $
			err_QDx_u = alog10(m_u/(1.-m_u))-QDx
	endif
	err_QDx = [-err_QDx_l, err_QDx_u]

	if (Qx[2] le 0.0) then QDy = 3.0 $
	else QDy = 3.*Qx[0]/Qx[2]
	if (Qx[0] le 0.0 or err_Qx[0] lt 0.0 $
		or Err_Qx[2] lt 0.0) then err_QDy = 3. $
	else err_QDy = QDy * sqrt((err_Qx[0]/Qx[0])^2. +(err_Qx[2]/Qx[2])^2.);

	; 0.8 is correction factor #3.
	if not keyword_set(nofixerror) then ec3 = 0.8 $
	else ec3 = 1.0

	if (QDy - err_QDy le 0.0) then err_QDy_l = QDy $
	else err_QDy_l = ec3 * err_QDy
	if (QDy + err_QDy ge 3.0) then err_QDy_u = 3.-QDy $
	else err_QDy_u = ec3 * err_QDy

	err_QDy = [-err_QDy_l, err_QDy_u]

	frac=frac[3:*]
	Ex = Ex[3:*]
	err_Ex = err_Ex[3:*]
	Qx = Qx[3:*]
	err_Qx = err_Qx[3:*]


end

function quantile, frac, src, range=range,  $
	bkg, ratio=ratio, $
	err_Ex=err_Ex, $
	Qx=Qx, err_Qx=err_Qx, $
	QDx=QDx, QDy=QDy, $
	err_QDx=err_QDx, err_QDy=err_QDy, $
	Nip=Nip, $
	nosort=nosort, $
	nofixerror=nofixerror

; src_ph and bkg_ph should be sorted

if not keyword_set(nosort) then begin
	order=sort(src)
	src=src[order]
endif

frac=[0.25,0.50,0.75,frac]

if not keyword_set(bkg) then begin
	ans = qt_simple(frac, src, range=range, err_Ex=err_Ex)
	n_src = n_elements(src)
	n_net = n_src
	if not keyword_set(nofixerror) then $
		err_Ex=qt_fix_err(ans,err_Ex,n_net,n_src,range=range)

	qt_qccd, range, frac=frac, Ex=ans, err_Ex=err_Ex, $
		Qx=Qx, err_Qx=err_Qx, $
		QDx=QDx, QDy=QDy, $
		err_QDx=err_QDx, err_QDy=err_QDy, $
		nofixerror=nofixerror
	
	return,ans
endif

if not keyword_set(nosort) then begin
	order=sort(bkg)
	bkg=bkg[order]
endif

n_src = n_elements(src)
n_bkg = n_elements(bkg)
if 0 eq n_elements(ratio) then ratio = 1.0

n_net = (n_src-ratio*n_bkg)>0

if n_net le 0.5 then begin
	ans=interpol(range, [0.,1.0], frac)
	err_Ex = (ans-range[0])>(range[1]-ans)
	qt_qccd, range, frac=frac, Ex=ans, err_Ex=err_Ex, $
		Qx=Qx, err_Qx=err_Qx, $
		QDx=QDx, QDy=QDy, $
		err_QDx=err_QDx, err_QDy=err_QDy, $
		nofixerror=nofixerror
	
	return, ans
endif

if not keyword_set(Nip) then Nip=2000 ; interpolation points
Narr = findgen(Nip)
ifrac=(Narr+0.5)/Nip
iE = Narr/Nip*(range[1]-range[0])+range[0]

iqt_src = qt_os(ifrac, src, range=range)
ic_src=interpol(n_src*ifrac, iqt_src, iE)

iqt_bkg = qt_os(ifrac, bkg, range=range)
ic_bkg=interpol(n_bkg*ifrac, iqt_bkg, iE)

; forward
ic_src = (ic_src>0.0)<n_src
ic_bkg = (ic_bkg>0.0)<n_bkg
ic_net = ic_src - ic_bkg*ratio
ic_net = (ic_net>0.0)<n_net
for i=1, Nip-1 do $
	if ic_net[i] lt ic_net[i-1] then ic_net[i]=ic_net[i-1]

;backward
ic_src_ = n_src-ic_src
ic_bkg_ = n_bkg-ic_bkg
ic_net_ = ic_src_ - ic_bkg_*ratio
ic_net_ = (ic_net_>0.0)<n_net
for i=Nip-2,0,-1 do $
	if ic_net_[i] lt ic_net_[i+1] then ic_net_[i]=ic_net_[i+1]

; average forward and backword
net_frac = (ic_net-ic_net_+n_net)/2./n_net
ans = interpol(iE, net_frac, frac)

w=where(finite(ans),cw)
n_frac=n_elements(frac)
if cw ne n_frac then print,'warning : some elements are not finite'

; now in order to estimate the error
; regenerate photons based on distribution
n_net_ = long(n_net+0.5)
;print,n_net,n_net_
tqt = (findgen(n_net_)*2+1.)/n_net_/2.
ip_src_ph = interpol(iE, net_frac, tqt)
err_Ex = qt_err_mj(frac, ip_src_ph, range=range)

if not keyword_set(nofixerror) then $
	err_Ex=qt_fix_err(ans,err_Ex,n_net,n_src,range=range)
qt_qccd, range, frac=frac, Ex=ans, err_Ex=err_Ex, $
	Qx=Qx, err_Qx=err_Qx, $
	QDx=QDx, QDy=QDy, $
	err_QDx=err_QDx, err_QDy=err_QDy, $
	nofixerror=nofixerror
	
return, ans
end
;------------------------------------------------------------------------


