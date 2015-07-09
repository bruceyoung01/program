; $Id: rectangle.pro,v 1.1.1.1 2003/10/22 18:09:37 bmy Exp $


pro rectangle,corners,xvec,yvec,expand=expand

    ; converts a vector with corner coordinates into 
    ; x and y vectors that can be used with plots or polyfill
    ; corners is assumed as X0, Y0, X1, Y1
    ; for maps, simply exchange xvec and yvec

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

