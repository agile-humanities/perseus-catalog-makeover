xquery version "3.1";

import module namespace util = "http://exist-db.org/xquery/util";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace efrbroo = "http://erlangen-crm.org/efrbroo/";
declare namespace dcterms = "http://purl.org/dc/terms";


declare function local:author-of($ctsurn as xs:string)
{
    let $hits := collection('/db/PerseusCatalogData/indexes/worksby')//edition[@ctsurn=$ctsurn]/ancestor::worksby/@authorid
    for $hit in $hits return xs:string($hit)
};

declare function local:author-name($urn)
{
    doc('/db/PerseusCatalogData/cite/authors.xml')//author[urn=$urn]/authority-name
};

declare function local:lyra() {
for $m in collection('/db/PerseusCatalogData/mods')//mods:title[. = 'Lyra Graeca']/ancestor::mods:mods
let $titleinfo := $m/mods:titleInfo[1]
let $ctsurn := $m/mods:identifier[@type = 'ctsurn']
let $authorids := local:author-of($ctsurn)
let $volume := $m/mods:relatedItem[@type = 'host']/mods:titleInfo/mods:partNumber
order by $volume, $ctsurn
return
    <item ctsurn="{ xs:string($ctsurn)}">
        { for $a in $authorids return
            <author id="{$a}">{xs:string(local:author-name($a))}</author> }
        <title>{ normalize-space(xs:string($titleinfo)) }</title>
        <volume>{ normalize-space(xs:string($volume)) }</volume>
    </item>
};

<items>{
local:lyra()
}</items>