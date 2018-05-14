xquery version "3.1";

(:~
 : A tool to process all current MODS data in the Perseus Catalog
 : into RDF-ready MODS.
 :)

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace xlink="http://www.w3.org/1999/xlink";

declare copy-namespaces no-preserve, inherit;


declare function local:single-embedded-host-records()
{

let $doublehosts := collection('/db/PerseusCatalogData/mods')/mods:mods/mods:relatedItem[@type='host' and not(mods:relatedItem[@type='host'])]
for $hosts in $doublehosts
let $titles := normalize-space($hosts/mods:titleInfo[1]/mods:title)
group by $titles
return
    <mods xmlns="http://www.loc.gov/mods/v3" displayLabel="{normalize-space($titles[1])}">
        <titleInfo>
                { $hosts[1]/mods:titleInfo/mods:title }
        </titleInfo>

        { $hosts[1]/mods:name }
        { $hosts[1]/mods:originInfo }
        { $hosts[1]/mods:identifier }
        { $hosts[1]/mods:classification }
        { $hosts[1]/mods:subject }
        { $hosts[1]/mods:location }        

    {
        for $h in $hosts
        group by $part := normalize-space($h/mods:titleInfo[1]/mods:partNumber[1])
        return
            if ($part) then
            <relatedItem xmlns="http://www.loc.gov/mods/v3" type='constituent' otherType='volume' displayLabel="{normalize-space($part[1])}">
                <part type='volume'>
                    <detail type='volume'>
                        <title>{ normalize-space($part[1]) }</title>
                    </detail>
                </part>
              {
               for $c in $h
                let $ctsurn := xs:string($c/ancestor::mods:mods/mods:identifier[@type='ctsurn'])
                let $work := replace($ctsurn,'^(.*)\..*$','$1')
                let $title := normalize-space($c/ancestor::mods:mods/mods:titleInfo[1])
                group by $work
                return 
                    <mods:relatedItem type='constituent' otherType='work' displayLabel="{$title[1]}">
                    <mods:identifier type='ctsurn'>{ $work }</mods:identifier>
                    {
                        for $m in $c 
                        let $m-urn := xs:string($m/ancestor::mods:mods/mods:identifier[@type='ctsurn'])
                        let $m-title := normalize-space($m/ancestor::mods:mods/mods:titleInfo[1])
                        return
                        <mods:relatedItem type='constituent' othertype='manifestation' displayLabel="{$m-title}">
                          <mods:identifier type='ctsurn'>{$m-urn}-F3</mods:identifier>
                        </mods:relatedItem>
                    }
                    </mods:relatedItem>
              }
            </relatedItem>
            else 
                for $c in $h
                let $ctsurn := xs:string($c/ancestor::mods:mods/mods:identifier[@type='ctsurn'])
                let $work := replace($ctsurn,'^(.*)\..*$','$1')
                let $title := normalize-space($c/ancestor::mods:mods/mods:titleInfo[1])
                group by $work
                return 
                    <mods:relatedItem type='constituent' otherType='work' displayLabel="{$title[1]}">
                    <mods:identifier type='ctsurn'>{ $work }</mods:identifier>
                    {
                        for $m in $c 
                        let $m-urn := xs:string($m/ancestor::mods:mods/mods:identifier[@type='ctsurn'])
                        let $m-title := normalize-space($m/ancestor::mods:mods/mods:titleInfo[1])
                        return
                        <mods:relatedItem type='constituent' othertype='manifestation' displayLabel="{$m-title}">
                          <mods:identifier type='ctsurn'>{$m-urn}-F3</mods:identifier>
                        </mods:relatedItem>
                    }
                    </mods:relatedItem>
    }

    </mods>

};

declare function local:double-embedded-host-records()
{

let $doublehosts := collection('/db/PerseusCatalogData/mods')/mods:mods/mods:relatedItem[@type='host']/mods:relatedItem[@type='host' and not(mods:relatedItem[@type='host'])]
for $hosts in $doublehosts
let $titles := normalize-space($hosts/mods:titleInfo[1]/mods:title)
group by $titles
return
    <mods xmlns="http://www.loc.gov/mods/v3" displayLabel="{normalize-space($titles[1])}">
        <titleInfo>
                { $hosts[1]/mods:titleInfo/mods:title }
        </titleInfo>

        { $hosts[1]/mods:name }
        { $hosts[1]/mods:originInfo }
        { $hosts[1]/mods:identifier }
        { $hosts[1]/mods:classification }
        { $hosts[1]/mods:subject }

    {
        for $h in $hosts
        group by $part := normalize-space($h/mods:titleInfo[1]/mods:partNumber[1])
        return
            if ($part) then
            <relatedItem xmlns="http://www.loc.gov/mods/v3" type='constituent' otherType='volume' displayLabel="{normalize-space($part[1])}">
                <part type='volume'>
                    <detail type='volume'>
                        <title>{ normalize-space($part[1]) }</title>
                    </detail>
                </part>
              { $h[1]/mods:location }
              {
               for $c in $h
                let $ctsurn := xs:string($c/ancestor::mods:mods/mods:identifier[@type='ctsurn'])
                let $work := replace($ctsurn,'^(.*)\..*$','$1')
                let $title := normalize-space($c/ancestor::mods:mods/mods:titleInfo[1])
                group by $work
                return 
                    <mods:relatedItem type='constituent' otherType='work' displayLabel="{$title[1]}">
                    <mods:identifier type='ctsurn'>{ $work }</mods:identifier>
                    {
                        for $m in $c 
                        let $m-urn := xs:string($m/ancestor::mods:mods/mods:identifier[@type='ctsurn'])
                        let $m-title := normalize-space($m/ancestor::mods:mods/mods:titleInfo[1])
                        return
                        <mods:relatedItem type='constituent' othertype='manifestation' displayLabel="{$m-title}">
                          <mods:identifier type='ctsurn'>{$m-urn}-F3</mods:identifier>
                        </mods:relatedItem>
                    }
                    </mods:relatedItem>
              }
            </relatedItem>
            else
             ( $h[1]/mods:location,
               for $c in $h
                let $ctsurn := xs:string($c/ancestor::mods:mods/mods:identifier[@type='ctsurn'])
                let $work := replace($ctsurn,'^(.*)\..*$','$1')
                let $title := normalize-space($c/ancestor::mods:mods/mods:titleInfo[1])
                group by $work
                return 
                    <mods:relatedItem type='constituent' otherType='work' displayLabel="{$title[1]}">
                    <mods:identifier type='ctsurn'>{ $work }</mods:identifier>
                    {
                        for $m in $c 
                        let $m-urn := xs:string($m/ancestor::mods:mods/mods:identifier[@type='ctsurn'])
                        let $m-title := normalize-space($m/ancestor::mods:mods/mods:titleInfo[1])
                        return
                        <mods:relatedItem type='constituent' othertype='manifestation' displayLabel="{$m-title}">
                          <mods:identifier type='ctsurn'>{$m-urn}-F3</mods:identifier>
                        </mods:relatedItem>
                    }
                    </mods:relatedItem>
               )
    }

    </mods>

};

declare function local:triple-embedded-host-records()
{

let $doublehosts := collection('/db/PerseusCatalogData/mods')/mods:mods/mods:relatedItem[@type='host']/mods:relatedItem[@type='host']/mods:relatedItem[@type='host']
for $hosts in $doublehosts
let $titles := normalize-space($hosts/mods:titleInfo[1]/mods:title)
group by $titles
return
    <mods xmlns="http://www.loc.gov/mods/v3" displayLabel="{normalize-space($titles[1])}">
        <titleInfo>
                { $hosts[1]/mods:titleInfo/mods:title }
        </titleInfo>

        { $hosts[1]/mods:name }
        { $hosts[1]/mods:originInfo }
        { $hosts[1]/mods:identifier }
        { $hosts[1]/mods:classification }
        { $hosts[1]/mods:subject }

    {
        for $h in $hosts
        group by $part := normalize-space($h/mods:titleInfo[1]/mods:partNumber[1])
        return 
            if ($part) then

            <relatedItem xmlns="http://www.loc.gov/mods/v3" type='constituent' otherType='volume' displayLabel="{normalize-space($part[1])}">
                <part type='volume'>
                    <detail type='volume'>
                        <title>{ normalize-space($part[1]) }</title>
                    </detail>
                </part>
            { $h[1]/mods:location }
              {
               for $c in $h
                let $ctsurn := $c/ancestor::mods:mods/mods:identifier[@type='ctsurn']
                let $work := replace($ctsurn,'^(.*)\..*$','$1')
                let $title := normalize-space($c/ancestor::mods:mods/mods:titleInfo[1])
                group by $work
                return 
                    <mods:relateditem type='constituent' otherType='work' displayLabel="{$title[1]}">
                    <mods:identifier type='ctsurn'>{ $work }</mods:identifier>
                    {
                        for $m in $c 
                        let $m-urn := xs:string($m/ancestor::mods:mods/mods:identifier[@type='ctsurn'])
                        let $m-title := normalize-space($m/ancestor::mods:mods/mods:titleInfo[1])
                        return
                        <mods:relatedItem type='constituent' othertype='manifestation' displayLabel="{$m-title}">
                          <mods:identifier type='ctsurn'>{$m-urn}-F3</mods:identifier>
                        </mods:relatedItem>
                    }
                    </mods:relateditem>
              }
            </relatedItem>
            else 
            ( $h[1]/mods:location,
                for $c in $h
                let $ctsurn := $c/ancestor::mods:mods/mods:identifier[@type='ctsurn']
                let $work := replace($ctsurn,'^(.*)\..*$','$1')
                let $title := normalize-space($c/ancestor::mods:mods/mods:titleInfo[1])
                group by $work
                return 
                    <mods:relateditem type='constituent' otherType='work' displayLabel="{$title[1]}">
                    <mods:identifier type='ctsurn'>{ $work }</mods:identifier>
                    {
                        for $m in $c 
                        let $m-urn := xs:string($m/ancestor::mods:mods/mods:identifier[@type='ctsurn'])
                        let $m-title := normalize-space($m/ancestor::mods:mods/mods:titleInfo[1])
                        return
                        <mods:relatedItem type='constituent' othertype='manifestation' displayLabel="{$m-title}">
                          <mods:identifier type='ctsurn'>{$m-urn}-F3</mods:identifier>
                        </mods:relatedItem>
                    }
                    </mods:relateditem> )
    }

    </mods>

};

declare function local:invert-mods() {
    let $triples := local:triple-embedded-host-records()
    let $doubles := local:double-embedded-host-records()
    let $singles := local:single-embedded-host-records() 
    return
    <modsCollection xmlns="http://www.loc.gov/mods/v3"  xmlns:xlink="http://www.w3.org/1999/xlink">
    {
        for $item in $triples union $doubles union $singles
        order by $item/@displayLabel
        return $item
    }
    </modsCollection>
};

local:invert-mods()
