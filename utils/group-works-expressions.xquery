xquery version "3.1";

(: Generates a list of all the cts urns in catalog_data :)

declare namespace mods = "http://www.loc.gov/mods/v3";



(: abstraction for CTS objects. :)

declare function local:object($cts-urn as xs:string)
as element()
{
    let $regex := "^urn:cts:([^:]+):([^.]*)\.?([^.]*)?\.?(.*?)?$"
    let $result := fn:analyze-string($cts-urn, $regex)
    return 
        if ($result/fn:match) then
            $result/fn:match
        else
            error((), "not a cts urn: |" || $cts-urn ||'|')
};

declare function local:valid-cts-urn-p($str as xs:string)
{
    let $regex := "^urn:cts:([^:]+):([^.]*)\.([^.]*)\.?(.*?)?$"
    let $result := fn:analyze-string($str, $regex)/fn:match
    return not(empty($result/fn:group[@nr=1]) or empty($result/fn:group[@nr=2]) or empty($result/fn:group[@nr=3]))
};


declare function local:work($cts-object as element())
as xs:string
{
        xs:string($cts-object/fn:group[@nr=3])
};

declare function local:edition($cts-object as element())
as xs:string
{
    xs:string($cts-object/fn:group[@nr=4])
};


declare function local:namespace($cts-object as element())
as xs:string
{
    xs:string($cts-object/fn:group[@nr=1])
};

declare function local:textgroup($cts-object as element())
as xs:string
{
    xs:string($cts-object/fn:group[@nr=2])
};

<textgroups>{
let $hits := collection('/db/PerseusCatalogData')//mods:identifier[@type='ctsurn']
let $cleaned := 
    for $id in distinct-values($hits)
    return normalize-space($id)
(: group them by work :)
for $urn in $cleaned
let $obj := local:object($urn)
group by $tg := local:textgroup($obj)
order by $tg
return
<textgroup id="urn:cts:{local:namespace($obj[1])}:{$tg}">{
    for $urn-in-group in $urn
    group by $work := local:work(local:object($urn-in-group[1]))
    order by $work
    return
    <work id="urn:{local:namespace(local:object($urn-in-group[1]))}:{$tg}.{$work}">{
        for $u in $urn-in-group order by $u return
        <expr id="{$u}"/>
    }</work>
}</textgroup>

}</textgroups>

