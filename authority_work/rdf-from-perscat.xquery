xquery version "3.1";

(:~
 : A set of interim queries to convert already-existing
   Perseus data into RDF. Once the migration is complete, these
   should no longer be used.
 :)

declare namespace mads = "http://www.loc.gov/mads/v2";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace dcterms = "http://purl.org/dc/terms";
declare namespace efrbroo = "http://erlangen-crm.org/efrbroo/";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace schema = "http://schema.org/";

declare function local:author($mads) {
    let $urn := normalize-space($mads/mads:identifier[@type = 'citeurn'])
    let $label := normalize-space($mads/mads:authority[1]/mads:name[1])
    let $viafurl := $mads/mads:url[@displayLabel = 'VIAF']
    return
        <efrbroo:F10_Person
            rdf:about="{$urn}">
            <efrbroo:P48_has_preferred_identifier>{$urn}</efrbroo:P48_has_preferred_identifier>
            <rdfs:label>{$label}</rdfs:label>
            <skos:prefLabel>{$label}</skos:prefLabel>
            {
                if ($viafurl) then
                    <schema:sameAs
                        rdf:resource="{$viafurl}"/>
                else
                    ()
            }
        </efrbroo:F10_Person>
};

declare function local:authors() {
    for $rec in collection('/db/PerseusCatalogData/mads/PrimaryAuthors')/mads:mads
    return
        local:author($rec)
};

declare function local:manifestation($mods) {
    let $ctsurn := normalize-space($mods/mods:identifier[@type = 'ctsurn'])
    let $m-urn := concat($ctsurn, '-F3')
    let $workurn := replace($ctsurn, '^(.*)\..*$', '$1')
    let $label := normalize-space($mods/mods:titleInfo[1])
    return
        <efrbroo:F3_Manifestation_Product_Type
            rdf:about="{$m-urn}">
            <rdfs:label>{$label}</rdfs:label>
            <efrbroo:P48_has_preferred_identifier>{$m-urn}</efrbroo:P48_has_preferred_identifier>
            <efrbroo:CLR6_should_carry>
                <efrbroo:F24_Publication_Expression>
                    <efrbroo:R19_realises>
                        <efrbroo:F1_Work>
                            <efrbroo:R10i_is_member_of
                                rdf:resource="{$workurn}"/>
                        </efrbroo:F1_Work>
                    </efrbroo:R19_realises>
                </efrbroo:F24_Publication_Expression>
            </efrbroo:CLR6_should_carry>
        </efrbroo:F3_Manifestation_Product_Type>
};

declare function local:manifestations() {
    for $rec in collection('/db/PerseusCatalogData/mods/greekLit')/mods:mods
    return
        local:manifestation($rec)
};

<rdf:RDF
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:schema="http://schema.org/">
    {local:manifestations()}
</rdf:RDF>