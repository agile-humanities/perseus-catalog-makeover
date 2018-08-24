xquery version "3.1";

import module namespace util = "http://exist-db.org/xquery/util";
declare namespace mads = "http://www.loc.gov/mads/v2";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace efrbroo = "http://erlangen-crm.org/efrbroo/";
declare namespace dcterms = "http://purl.org/dc/terms";

declare function local:padleft($str as xs:string, $padchar as xs:string, $len as xs:int) as xs:string
{
    if (string-length($str) >= $len)
        then $str
    else local:padleft(concat($padchar, $str), $padchar, $len)
};

declare function local:phi-id($idstring as xs:string) {
    let $tokens := tokenize($idstring, '\.')
    return
    if (count($tokens) = 2) then
       "phi" || local:padleft($tokens[1], '0', 4) || ".phi" || local:padleft($tokens[2], '0', 3)
    else "NNNNnnnnnn"
};

declare function local:stoa-id($idstring as xs:string) as xs:string
{
    string-join((tokenize($idstring, '-')), '.')
};

declare function local:phi-id-of($row) as xs:string?
{
    if ($row/PHI_ and not(empty($row/PHI_)) and not($row/PHI_/text() = "none"))
        then normalize-space($row/PHI_[1])
        else ()
};

declare function local:stoa-id-of($row) as xs:string?
{
if ($row/STOA_ and not(empty($row/STOA_)) and not($row/STOA_/text() = "none"))
        then normalize-space($row/STOA_[1])
        else ()
};

declare function local:ctsurn-of($row as element())
as xs:string
{
    let $prefix := "urn:cts:LatinLit:"
    return
    if ($row/PHI_ and not(empty($row/PHI_)) and not($row/PHI_/text() = "none"))
        then concat($prefix, local:phi-id(normalize-space($row/PHI_[1])))
    else if ($row/STOA_ and not(empty($row/STOA_)) and not($row/STOA_/text() = "none"))
        then concat($prefix, local:stoa-id(normalize-space($row/STOA_[1])))
    else "XXXXXXXXX"
};

declare function local:textgroup-of($ctsurn as xs:string) as xs:string?
{
    let $textgroup := tokenize(tokenize($ctsurn, ':')[4], '\.')[1]
    return
        if ($textgroup) then
            concat('urn:cts:latinLit:', $textgroup)
        else ()
};

declare function local:mads-for($row as element())
as element()
{
    let $ctsurn := local:ctsurn-of($row)
    let $label  := normalize-space($row/WORK_TITLE)
    return
        <mads xmlns="http://www.loc.gov/mads/v2"
              xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
              xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
              xmlns:dcterms="http://purl.org/dc/terms"
              xmlns:efrbroo="http://erlangen-crm.org/efrbroo/">
            <authority>
                <titleInfo>
                    <title>{$label}</title>
                </titleInfo>
            </authority>
            <identifier type='ctsurn'>{$ctsurn}</identifier>
            { if (local:phi-id-of($row)) then
                <identifier type='phi'>{ local:phi-id-of($row) }</identifier>
              else ()
            }
            { if (local:stoa-id-of($row)) then
                <identifier type='stoa'>{ local:stoa-id-of($row) }</identifier>
              else ()
            }            
            <extension>
                <rdf:RDF
                    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                    xmlns:dcterms="http://purl.org/dc/terms"
                    xmlns:efrbroo="http://erlangen-crm.org/efrbroo/">
                    <efrbroo:F1_Work rdf:about="{$ctsurn}">
                        <rdfs:label>{$label}</rdfs:label>
                        <efrbroo:P1_is_identified_by>{ $ctsurn }</efrbroo:P1_is_identified_by>
                                    { if (local:phi-id-of($row)) then
                <efrbroo:P1_is_identified_by>{ local:phi-id-of($row) }</efrbroo:P1_is_identified_by>
              else ()
            }
            { if (local:stoa-id-of($row)) then
                <efrbroo:P1_is_identified_by>{ local:stoa-id-of($row) }</efrbroo:P1_is_identified_by>
              else ()
            }  
                        <dcterms:isPartOf rdf:resource="{ local:textgroup-of($ctsurn) }"/>
                        <efrbroo:R10i_is_member_of rdf:resource="{local:textgroup-of($ctsurn) }"/>
                    </efrbroo:F1_Work>
                </rdf:RDF>
            </extension>
        </mads>
};

let $rows := doc('/db/spreadsheet_data/LatinAuthors.xml')//row
return 
<madsCollection xmlns="http://www.loc.gov/mads/v2"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:dcterms="http://purl.org/dc/terms"
                xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
>
{ for $row in $rows return local:mads-for($row) }
</madsCollection>