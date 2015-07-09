function color_index, num

if n_elements(num) eq 0 then num=7
inc = 120/num

index = reverse(119-indgen(num)*inc)

return, index
end
