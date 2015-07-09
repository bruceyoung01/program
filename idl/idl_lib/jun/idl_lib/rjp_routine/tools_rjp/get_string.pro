
 function get_string, Category

  CATEGORY = strupcase(category)

  CASE category of
   'SEASON'  : String = ['DJF','MAM','JJA','SON']
   'MONTH'   : String = ['JAN','FEB','MAR','APR','MAY','JUN', $
                         'JUL','AUG','SEP','OCT','NOV','DEC' ]
  End

 Return, string

 End
