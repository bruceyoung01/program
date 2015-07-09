; $Id: is_defined.pro,v 1.1.1.1 2003/10/22 18:09:41 bmy Exp $
function is_defined,arg

    ; from David Fanning, got it from newsgroup on 2 Jul 1998

    return,keyword_set(n_elements(arg))

end

