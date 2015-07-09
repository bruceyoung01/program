function blank_pad (str, length) ; extend a string to fixed length
begin
   nextra = length - strlen (str)
   if (nextra .ge. 1) then
      bbb = new (nextra, string)
      bbb(:) = " "
      return (str + str_concat (bbb))
   else
      return (str)
   end if
end

begin

; READ wrfinput DATA
  dir   = "/home/bruce/sshfs/pf/model/wrfchem4/WRFV3/test/em_real/sixteen_pt_four_pt_average_4pt/"
  filer = "wrfout_d01_2008-05-11_00:00:00.nc"

   infile = dir+filer
   outfile = "statements_read_out.ncl"
   file_var_name = "in" ; file variable name in target NCL program
   max_nelements = 1e6 ; vars larger than this size are excluded
   print ("Open input file.")
   in = addfile (infile, "r")
   vars = getfilevarnames (in)
   nvars = dimsizes (vars)

   width = max (strlen (vars)) + 2 ; longest name length, plus spacer
   width = max ((/ width, 11 /)) ; minimum with for title
   print ("Generate NCL input statements.")
   print (" " + blank_pad ("Var name", width) \
      + "Rank Total elements Included")

   stmts = new (nvars, string)
   include = new (nvars, logical)

   do i = 0, nvars-1
      dims = getfilevardimsizes (in, vars(i))
      rank = dimsizes (dims)
      nelements = product (dims + 0.0)
      include(i) = (nelements .le. max_nelements)
      yesno = where (include(i), "Yes", "No")
      print (" " + blank_pad (vars(i), width) + sprinti ("%4i", rank) \
         + sprintf ("%17.0f", nelements) + " " + yesno)
      stmts(i) = " " + vars(i) + " = " + file_var_name + "->" + vars(i)
      delete (dims)
   end do

   print ("Number of variables in file = " + nvars)
   print ("Number included in output = " + num (include))
   print ("Write output file: " + outfile)

   asciiwrite (outfile, stmts(ind(include)))
end
