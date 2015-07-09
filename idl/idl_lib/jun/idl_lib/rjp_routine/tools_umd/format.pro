function format,var,sformat=sformat

;var : float variable
;sformat : desired format 

if n_elements(sformat) eq 0 then sformat = '5.2'

nn = strmid(sformat,0,1) 
nn2 = strmid(sformat,1,10) 

case 1 of 
(nn eq 'f'): sformat2 = '(f'+nn2+')'
(nn eq 'i'): sformat2 = '(i'+nn2+')'
(nn eq 'e'): sformat2 = '(e'+nn2+')'
else: sformat2 = '(f'+string(sformat)+')' 
endcase 

string2 = string(var,format=sformat2)

return,string2
end 
