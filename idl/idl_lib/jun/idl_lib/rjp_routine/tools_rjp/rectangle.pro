;+
; NAME:
;    rectangle
;
; PURPOSE:
;    This procedure converts a vector with rectangle corner
;    coordinates into two vectors with x and y coordinates which can
;    be used with PLOTS, POLYFILL etc. The corner coordinate must be
;    given as [X0, Y0, X1, Y1]. The optional expand keyword allows to
;    calculate a somewhat larger rectangle.
;
; USAGE:
;    rectangle,corners,xvec,yvec,expand=expand
;
;    Tip: to convert e.g. a limit vector from map_set, exchange the
;    xvec and yvec results.
;
; CATEGORY:
;    General Graphics
;
; MODIFICATION HISTORY:
;    mgs, some time 1999: VERSION 1.0
;    mgs, 26 Aug 2000: - added header and copyright
;-
;
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 2000 Martin Schultz
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;###########################################################################


pro rectangle,corners,xvec,yvec,expand=expand

    xvec = [ 0 ]
    yvec = [ 0 ]

    if (n_elements(corners) ne 4) then return

    if (n_elements(expand) eq 0) then expand = 0.


    xvec = [ corners[0]-expand, corners[2]+expand, $
             corners[2]+expand, corners[0]-expand, corners[0]-expand ]
    yvec = [ corners[1]-expand, corners[1]-expand, $
             corners[3]+expand, corners[3]+expand, corners[1]-expand ]

    return
end

