declare namespace mods="http://www.loc.gov/mods/v3";

let $hits :=  //mods:mods[.//mods:title='Fragmenta historicorum graecorum']

for $hit in $hits
let $volume := $hit/mods:relatedItem[@type='host']/mods:titleInfo/mods:partNumber


group by $volume
return
    <relatedItem type="constituent" otherType="section" displayLabel="{$volume}">
    { for $item in $hit
        let $title := $item/mods:titleInfo[1]/mods:title/text()
        let $fhg-num := $item/mods:titleInfo[@displayLabel="FHG"]/mods:title/text()
        let $fgrh-num := $item/mods:titleInfo[@displayLabel="FGrH"]/mods:title/text()
        let $creator := $item/mods:name[mods:role/mods:roleTerm='creator']
        let $creator-label := string-join(($creator/mods:namePart[1], $creator/mods:namePart[2]), ' ')
        let $tlg-num := $item/mods:identifier[@type='tlg']/text()
        let $part-info := $item/mods:part
        let $locations := $item/mods:location
        order by $creator-label
        return
     <relatedItem type="constituent" otherType="section" displayLabel="{$creator-label}">
     { $item/mods:titleInfo[1] }
     { $creator }
     { if ($fhg-num) then
                <part type="FHG">
            <detail>
                <title>{$fhg-num}</title>
            </detail>
        </part>
        else ()     
     }
     { if ($fgrh-num) then

        <part type="FGrH">
            <detail>
                <title>{$fgrh-num}</title>
            </detail>
        </part>
        else ()     
     }
     { if ($part-info) then
         let $start := $part-info/mods:extent/mods:start/text()
         let $end := $part-info/mods:extent/mods:end/text()
         return
           <part>
            <extent unit="pages">
                <start>{$start}</start>
                <end>{$end}</end>
                </extent>
           </part>
        else ()
     }
       <relatedItem type="constituent" otherType="work" displayLabel="{$title}">
         <identifier type="tlg">{$tlg-num}</identifier>
         <relatedItem type="constituent" otherType="expression">
         {$locations}
         </relatedItem>
       </relatedItem>
     </relatedItem>
     
     }
    </relatedItem>

