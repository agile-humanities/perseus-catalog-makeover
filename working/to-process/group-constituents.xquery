xquery version "3.1";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mads="http://www.loc.gov/mads/v2";

for $c in doc('/db/PerseusCatalogData/work/constituents.xml')//constituents/constituent
let $ctsurn := xs:string($c/@ctsurn)
let $volume := collection('/db/PerseusCatalogData/mods')//mods:identifier[@type='ctsurn' and . = $ctsurn]/ancestor::mods:mods/mods:relatedItem[@type='host']/mods:titleInfo[1]/mods:partNumber

let $textgroup := replace($ctsurn[1],'^(.*?)\..*$', '$1')
let $name := collection('/db/PerseusCatalogData/authorities/textgroups')//mads:identifier[@type="ctsurn" and . = $textgroup]/ancestor::mads:mads//mads:title/text()
group by $textgroup
order by $volume[1]
order by $name[1]
return
    <group urn="{$textgroup}" name="{$name[1]}">
    {
    for $const in $c
    let $urn := $const/@ctsurn
    let $volume := collection('/db/PerseusCatalogData/mods')//mods:identifier[@type='ctsurn' and . = $urn]/ancestor::mods:mods/mods:relatedItem[@type='host']/mods:titleInfo[1]/mods:partNumber
    let $work := replace($urn, '^(.*)\..*$', '$1')
    group by $work
    return
        <work ctsurn="{$work}" volume="{$volume[1]}">
        <title>{ normalize-space(xs:string($const[1]/mods:titleInfo/mods:title)) }</title>
        {
          for $u in $urn
          return <expression ctsurn="{$u}"/> 
        }
        </work>

    }
    </group>
