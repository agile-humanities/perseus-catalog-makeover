xquery version "3.1";

declare namespace mods="http://www.loc.gov/mods/v3";


let $old-mods-ids := distinct-values( 
    for $modsid in collection('/db/PerseusCatalogData/mods')//mods:identifier[@type='ctsurn']
    return normalize-space($modsid))
    
let $new-mods-ids := distinct-values( 
    for $modsid in collection('/db/PerseusCatalogData/inverted')//mods:identifier[@type='ctsurn'] 
    return normalize-space($modsid))

for $id in $old-mods-ids
where not($id = $new-mods-ids)
return $id

