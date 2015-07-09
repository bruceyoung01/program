file = '/users/ctm/rjp/Asim/icartt/output/IJ-AVG_2004_06-08.2x25.bpch'

ctm_get_data, datainfo, 'oc-biob', file=file

data = 0.
for d = 0, n_elements(datainfo)-1 do data = data + *(datainfo[D].data)

ctm_get_data, datainfo, 'bc-biob', file=file
for d = 0, n_elements(datainfo)-1 do data = data + *(datainfo[D].data)


na = region_only(data, region='NAMERICA')

   
end
