; $ID:


undef("read_asc6")
procedure read_asc6(dir    :string, filename  :string, \ ; INPUT
                    n_new_layer :integer,              \ ; INPUT
                    height :float,  aod       :float,  \ ; OUTPUT
                    fre    :float,  error     :float)    ; OUTPUT

begin

data = asciiread(dir + filename, (/n_new_layer, 4/), "float")
height = data(:, 0)
aod    = data(:, 1)
fre    = data(:, 2)
error  = data(:, 3)

end
