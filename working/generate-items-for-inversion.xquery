xquery version "3.1";

declare namespace mods="http://www.loc.gov/mods/v3";

declare variable $coll := "/db/PerseusCatalogData/mods/greekLit";

declare function local:hosts-1() {
  for $h in collection($coll)//mods:relatedItem[@type='host']
  group by $h
  order by $h
  return $h
};

<data>{
for $host in local:hosts-1()
let $title := $host/mods:titleInfo[1]/mods:title
let $constituents := collection($coll)//mods:relatedItem[@type='host'][./mods:titleInfo/mods:title = $title]/ancestor::mods:mods
return
    <item title='{$title}' count='{count($constituents)}'>
    { $host }
    <constituents>{ 
        for $c in $constituents
        let $ctsurn := xs:string($c/mods:identifier[@type='ctsurn'])
        
        order by $c return 
        <constituent ctsurn="{$ctsurn}">{$c/mods:titleInfo[1]}</constituent> 
    
    }</constituents>
    </item>
}</data>