xquery version "3.1";


declare namespace mads = "http://www.loc.gov/mads/v2";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace efrbroo = "http://erlangen-crm.org/efrbroo/";
declare namespace dcterms = "http://purl.org/dc/terms";

(:~
    Converts string like "1891.001" to "tlg1891.tlg001"
:)
declare function local:tlg-prefix($idstring) {
    let $tokens := tokenize($idstring, '\.')
    return
        "tlg" || $tokens[1] || ".tlg" || $tokens[2]
};


declare function local:GreekWorks-to-mads()
{
    let $GreekAuthors := doc('/db/spreadsheet_data/GreekAuthors.xml')
    for $row in $GreekAuthors//row
    let $workTitle := normalize-space($row/WORK_TITLE)
    for $i in tokenize($row/TLG_, ",")
    where not($i = ('n.a.', 'none', 'no', '', 'uncertain', 'various'))
    let $tlg-prefix := local:tlg-prefix(normalize-space($i))
    let $tokens := tokenize($tlg-prefix, '/.')
    let $textgroup := $tokens[1]
    let $work := $tokens[2]
    let $textgroup-urn := string-join(('urn', 'cts', 'greekLit', $textgroup), ':')
    let $ctsurn := string-join(($textgroup-urn, $work), '.')
    return
        <mads
            xmlns="http://www.loc.gov/mads/v2">
            <authority>
                <titleInfo>
                    <title>{$workTitle}</title>
                </titleInfo>
            </authority>
            <identifier type='ctsurn'>{$ctsurn}</identifier>
            <identifier type='tlg'>{ $i }</identifier>
            <extension>
                <rdf:RDF
                    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                    xmlns:dcterms="http://purl.org/dc/terms"
                    xmlns:efrbroo="http://erlangen-crm.org/efrbroo/">
                    <efrbroo:F1_Work rdf:about="{$ctsurn}">
                        <rdfs:label>{$workTitle}</rdfs:label>
                        <efrbroo:P1_is_identified_by>{ $ctsurn }</efrbroo:P1_is_identified_by>
                        <efrbroo:P1_is_identified_by>{ $i }</efrbroo:P1_is_identified_by>
                        <dcterms:isPartOf rdf:resource="{$textgroup-urn}"/>
                        <efrbroo:R10i_is_member_of rdf:resource="{$textgroup-urn}"/>
                    </efrbroo:F1_Work>
                </rdf:RDF>
            </extension>
        </mads>
};

declare function local:row-to-rdf ($row) {
    let $workTitle := normalize-space($row/WORK_TITLE)
    for $i in tokenize($row/TLG_, ",")
    where not($i = ('n.a.', 'none', 'no', '', 'uncertain', 'various'))
     let $tlg-prefix := local:tlg-prefix(normalize-space($i))
     let $tokens := tokenize($tlg-prefix, '/.')
     let $textgroup := $tokens[1]
     let $work := $tokens[2]
     let $textgroup-urn := string-join(('urn', 'cts', 'greekLit', $textgroup), ':')
     let $ctsurn := string-join(($textgroup-urn, $work), '.')
    return
        <efrbroo:F1_Work rdf:about="{$ctsurn}">
            <rdfs:label>{$workTitle}</rdfs:label>
                <dcterms:isPartOf rdf:resource="{$textgroup-urn}"/>
                <efrbroo:R10i_is_member_of rdf:resource="{$textgroup-urn}"/>
        </efrbroo:F1_Work>    
};

declare function local:GreekWorks-to-rdf()
{
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
             xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
             xmlns:dcterms="http://purl.org/dc/terms"
             xmlns:efrbroo="http://erlangen-crm.org/efrbroo/">
     {
    let $GreekAuthors := doc('/db/spreadsheet_data/GreekAuthors.xml')
    for $row in $GreekAuthors//row
    return local:row-to-rdf($row)
     }             
    </rdf:RDF>
};


declare function local:GreekWorks_madsCollection() {
    let $works := local:GreekWorks-to-mads()
    return
        <madsCollection xmlns="http://www.loc.gov/mads/v2"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:dcterms="http://purl.org/dc/terms"
                xmlns:efrbroo="http://erlangen-crm.org/efrbroo/">
            {$works intersect $works}
        </madsCollection>
};


local:GreekWorks_madsCollection()