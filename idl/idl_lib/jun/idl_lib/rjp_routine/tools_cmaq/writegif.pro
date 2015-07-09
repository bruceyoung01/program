
 pro writegif, file=file

 if n_elements(file) eq 0 then file = 'graph.gif'

 tvlct, r, g, b, /get

 image = tvrd()

 write_gif, file, image, r, g, b

 end
