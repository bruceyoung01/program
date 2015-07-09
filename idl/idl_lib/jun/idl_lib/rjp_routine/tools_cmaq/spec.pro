function spec, in, ncon=ncon

if n_elements(in) eq 0 then return, -1
if n_elements(ncon) eq 0 then return, -1
type = size(in,/type)

case ncon of
  52 :  begin
gasname = ['NO',	$
           'NO2',	$
           'NO3',	$
           'N2O5',	$	
           'HONO',	$
           'HNO3',	$
           'HO2NO2',	$
           'O3',	$
           'H2O2',	$
           'CO',	$
           'C2H6',	$
           'C3H8',	$
           'HCHO',	$
           'CH3CHO', 	$
           'CH3O',	$
           'CH3O2',	$
           'CH3ONO2',	$
           'CH3O2NO2',	$
           'C2H5O2',	$
           'C2H5O2NO2',	$
           'C3H7O2',	$
           'CH3COCH3',	$
           'CH3COCH2O2',$
           'C2H4',	$
           'C3H6',	$
           'H2COO',	$
           'CH3HCOO',	$
           'CH3OOH',	$
           'HOC2H4O2',	$
           'HOC3H6O2',	$
           'CH3CO3',	$
           'CH3CO3NO2',	$
           'CH3COCHO',	$
           'ISOP',	$
           'ISOH',	$
           'MACR',	$
           'MVK',	$
           'MV1',	$
           'MV2',	$
           'MAC1',  	$
           'MAC2',	$
           'MPAN',	$
           'CH2CCH3CO3',$
           'ISNT',	$
           'ISNI1',	$
           'ISNI2',	$
           'ISNIR',	$
           'IPRX',	$
           'OH',	$
           'H2O',	$
           'HO2',	$
           'CH4']
      end
  20 :  begin

gasname = [	'NO',		$
           	'NO2',	$
		'NO3',	$
		'N2O5',	$
		'HNO3',	$
		'OH',		$
		'O3',		$
		'HO2',	$
		'H2O2',	$
		'CO',  	$
	 	'C2H6',	$
		'C3H8',	$
		'HCHO',	$
		'CH3COCH3',	$
		'C2H4',	$
		'C3H6',	$
		'CH3OOH',	$
		'CH3CO3NO2',$
		'ISOP',	$
		'MPAN']   
       end
  25 :  begin
gasname = [     'NO',   $
                'NO2',  $
                'NO3',  $
                'N2O5', $
                'HONO', $
                'HNO3', $
                'HO2NO2', $
                'OH',           $
                'O3',           $
                'HO2',  $
                'H2O2', $
                'CO',   $
                'C2H6', $
                'C3H8', $
                'HCHO', $
                'CH3ONO2', $
                'CH3O2NO2', $
                'C2H5O2NO2', $
                'CH3COCH3',     $
                'C2H4', $
                'C3H6', $
                'CH3OOH',       $
                'CH3CO3NO2',$
                'ISOP', $
                'MPAN']
       end
  else  :  begin
         print, 'Number of spec is not right'
         return, -1
       end
 end

case type of
 7 : begin  ; string type
     ngas = n_elements(in) & out = intarr(ngas) & out(*) = -1
     gas  = strupcase(in)
     for i = 0 , ngas-1 do begin
      for j = 0 , ncon-1 do begin
       if (gas(i) eq gasname(j)) then out(i) = j
      end
     end
    end
 2 : begin  ; integer type
     ngas = n_elements(in) & out = strarr(ngas)
     for i = 0, ngas-1 do begin
      for j = 0, ncon-1 do begin
       if (in(i) eq j) then out(i) = gasname(j)
      end
     end
    end    
 else : begin 
       print, 'wrong type of input'
       return, -1
    end
 end

 
 return, out
end
