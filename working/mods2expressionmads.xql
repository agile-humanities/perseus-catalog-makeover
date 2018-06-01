xquery version "3.1";
(:
 : Creates an expression-level MADS record for each MODS
 : record in the current catalog. The MADS includes in its
 : extension element the FRBRoo RDF for the expression.
 :)
import module namespace system = "http://exist-db.org/xquery/system";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace mads = "http://www.loc.gov/mads/v2";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dcterms = "http://purl.org/dc/terms";
declare namespace efrbroo = "http://erlangen-crm.org/efrbroo/";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";

declare function local:valid-ctsurnp($urn as xs:string) as xs:boolean
{
    matches($urn, '^urn:cts')
};

declare function local:expression-mads($mods as element()) as item()?
{
    let $urn := replace(normalize-space($mods/mods:identifier[@type = 'ctsurn'][1]), "^\s*(.*)\s*$", "$1")
    return
        if (local:valid-ctsurnp($urn)) then
            let $workid := replace($urn, "^(urn:cts:.*)\..*$", "$1")
            let $versionid := replace($urn, "^urn:cts:.*\.(.*)$", "$1")
            let $textgroup := replace($workid, "^(.*)\..*$", "$1" )
            let $label := normalize-space($mods/mods:titleInfo[1]/mods:title[1])
            return
            <mads:mads>
                <mads:authority>
                    <mads:titleInfo>
                        <mads:title>{ $label }</mads:title>
                    </mads:titleInfo>
                </mads:authority>
                <mads:identifier type='ctsurn'>{ $urn }</mads:identifier>
                <mads:extension>
                    <rdf:RDF>
                        <rdf:Description about="{$urn}">
                            <rdfs:label>{ $label }</rdfs:label>
                            <dcterms:isPartOf>{ $textgroup }</dcterms:isPartOf>
                        </rdf:Description>
                    </rdf:RDF>
                </mads:extension>
            </mads:mads>
        else
            ()
};

let $mods := collection('/db/PerseusCatalogData/mods/greekLit')//mods:mods
return
    <mads:madsCollection>{
            for $rec in $mods
            return local:expression-mads($rec)
        }</mads:madsCollection>