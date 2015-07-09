 function get_mask, file

  filter = '/users/ctm/rjp/Data/MAP/mask/'
  if N_elements(file) eq 0 then file = pickfile(filter=filter)

  ctm_get_data, datainfo, file=file
  mask = *(datainfo.data)

  return, mask
 end
