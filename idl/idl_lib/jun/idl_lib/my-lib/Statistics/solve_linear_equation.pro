; suppose we like to solve the equations:
; x  -  y + z = 2x
; x  + 2y + z = 2y
; 2x + 3y - z = 2z

; method 1, express equations so we can use matrix to solve it
; -x - y + z    = 0
; x + 0.y +z    = 0
; 2x + 3y - 3z  = 0

A = [ [-1, -1, 1], [1, 0, 1], [2, 3, -3] ]
print, 'A = '
print, A

B = [ 0, 0, 0]
Ainv = invert (A)
Sul = Ainv ## B
x = Sul(0)
y = Sul(1)
z = Sul(2)
print, 'Solution is'
print, 'X = ', X, ' Y= ', y, ' Z = ', Z 
end

