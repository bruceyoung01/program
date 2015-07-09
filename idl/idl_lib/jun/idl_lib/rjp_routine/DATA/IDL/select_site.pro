 function select_site, nsite=nsite

 if N_elements(nsite) eq 0 then nsite = 49

 Case nsite of 
   49 : begin
  ; All available sites
   Sites = [ $
   'DENA','REDW','PORE','MORA','CRLA','THSI','LAVO','SNPA','PINN','YOSE',$ 
   'SEQU','SAGO','JARB','GRBA','GLAC','BRCA','GRCA','LOPE','TONT','YELL',$ 
   'PEFO','CANY','BRID','CHIR','MEVE','WEMI','MOZI','BAND','ROMO','GRSA',$ 
   'GUMO','BIBE','BADL','UPBU','BOWA','SIPS','MACA','GRSM','SHRO','CHAS',$ 
   'OKEF','ROMA','DOSO','SHEN','WASH','BRIG','LYBR','ACAD','MOOS']
   end

   45 : begin
  ; Kick off sites with missing month
   Sites = [ $
   'DENA','REDW','PORE','MORA','CRLA','THSI','LAVO','SNPA','PINN','YOSE',$ 
   'SEQU','JARB','GRBA','GLAC','BRCA','LOPE','TONT',$ 
   'PEFO','CANY','BRID','CHIR','MEVE','WEMI','MOZI','BAND','ROMO','GRSA',$ 
   'GUMO','BIBE','BADL','UPBU','SIPS','MACA','GRSM','SHRO','CHAS',$ 
   'OKEF','ROMA','DOSO','SHEN','WASH','BRIG','LYBR','ACAD','MOOS']
   end

   44 : begin
  ; Kick BRIG off because of too much anthropogenic source
   Sites = [ $
   'DENA','REDW','PORE','MORA','CRLA','THSI','LAVO','SNPA','PINN','YOSE',$ 
   'SEQU','JARB','GRBA','GLAC','BRCA','LOPE','TONT',$ 
   'PEFO','CANY','BRID','CHIR','MEVE','WEMI','MOZI','BAND','ROMO','GRSA',$ 
   'GUMO','BIBE','BADL','UPBU','SIPS','MACA','GRSM','SHRO','CHAS',$ 
   'OKEF','ROMA','DOSO','SHEN','WASH','LYBR','ACAD','MOOS']
   end

   38 : begin
  ; Kick REDW, PORE, PINN, SEQU, GLAC, and OKEF sites associated with wildfire
   Sites = [ $
   'DENA','MORA','CRLA','THSI','LAVO','SNPA','YOSE',$ 
   'JARB','GRBA','BRCA','LOPE','TONT',$ 
   'PEFO','CANY','BRID','CHIR','MEVE','WEMI','MOZI','BAND','ROMO','GRSA',$ 
   'GUMO','BIBE','BADL','UPBU','SIPS','MACA','GRSM','SHRO','CHAS',$ 
   'ROMA','DOSO','SHEN','WASH','LYBR','ACAD','MOOS']
   end

   40 : begin
  ; Kick REDW, PORE, off 
   Sites = [ $
   'DENA','CRLA','LAVO','SNPA','YOSE',$ 
   'SAGO','JARB','GRBA','BRCA','GRCA','LOPE','TONT','YELL',$ 
   'PEFO','CANY','BRID','CHIR','MEVE','WEMI','MOZI','BAND','ROMO','GRSA',$ 
   'GUMO','BIBE','BADL','UPBU','BOWA','SIPS','MACA','GRSM','SHRO','CHAS',$ 
   'ROMA','DOSO','SHEN','WASH','LYBR','ACAD','MOOS']
   end

   36 : begin
  ; sites were selected to kick off a few outliers
  ; These sites should be used for statistical analysis
   Sites = [ $
   'DENA','CRLA','LAVO','SNPA','YOSE',$ 
   'JARB','GRBA','BRCA','LOPE','TONT',$ 
   'PEFO','CANY','BRID','CHIR','MEVE','WEMI','MOZI','BAND','ROMO','GRSA',$ 
   'GUMO','BIBE','BADL','UPBU','SIPS','MACA','GRSM','SHRO','CHAS',$ 
   'ROMA','DOSO','SHEN','WASH','LYBR','ACAD','MOOS']
   end
 Endcase

 Return, sites

 end
