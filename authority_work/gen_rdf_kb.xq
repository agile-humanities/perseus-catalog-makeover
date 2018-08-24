xquery version "3.1";


declare namespace mads = "http://www.loc.gov/mads/v2";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace efrbroo = "http://erlangen-crm.org/efrbroo/";
declare namespace dcterms = "http://purl.org/dc/terms";

declare function local:greek-authors($index as xs:int) {
    let $all-authors :=
        for $row in doc('/db/spreadsheet_data/GreekAuthors.xml')//row
        let $viaf := normalize-space($row/VIAF_URI)
        let $label := normalize-space($row/LC_or_VIAF_AUTHOR_NAME)
        group by $viaf
        order by $label[1]
        return <author viaf="{$viaf[1]}" label="{$label[1]}"/>
    for $a at $n in $all-authors
    order by $a/@label
    return
        <author n="{$index + $n}" viaf="{$a/@viaf}" label="{$a/@label}"/>
};

declare function local:latin-authors($index as xs:int) {
    let $all-authors :=
        for $row in doc('/db/spreadsheet_data/LatinAuthors.xml')//row
        let $viaf := normalize-space($row/VIAF_URI)
        let $label := normalize-space($row/LC_NAME_TITLE_or_VIAF_AUTHOR_NAME)
        group by $viaf
        order by $label[1]
        return <author viaf="{$viaf[1]}" label="{$label[1]}"/>
    for $a at $n in $all-authors
    order by $a/@label
    return
        <author n="{$index + $n}" viaf="{$a/@viaf}" label="{$a/@label}"/>
};

declare function local:authors() {
    let $greeks := local:greek-authors(0)
    let $latins := local:latin-authors(count($greeks))
    return ($greeks union $latins)
};

(:~
 : Adapting following functions from greekAAE.xq and LatinAAE.xq
 :)


(:~
    Converts string like "1891.001" to "tlg1891.tlg001"
:)
declare function local:tlg-prefix($idstring) {
    let $tokens := tokenize($idstring, '\.')
    return
        "tlg" || $tokens[1] || ".tlg" || $tokens[2]
};

declare function local:GreekWorks($index as xs:int)
{
    let $GreekAuthors := doc('/db/spreadsheet_data/GreekAuthors.xml')
    for $row at $n in $GreekAuthors//row
    let $workTitle := normalize-space($row/WORK_TITLE)
    for $i at $m in tokenize($row/TLG_, ",")
    where not($i = ('n.a.', 'none', 'no', '', 'uncertain', 'various'))
    let $tlg-prefix := local:tlg-prefix(normalize-space($i))
    let $tokens := tokenize($tlg-prefix, '/.')
    let $textgroup := $tokens[1]
    let $work := $tokens[2]
    let $textgroup-urn := string-join(('urn', 'cts', 'greekLit', $textgroup), ':')
    let $ctsurn := string-join(($textgroup-urn, $work), '.')
    return
        <work n="{$index + $n + ($m - 1)}" ctsurn="{$ctsurn}" tlg="{$i}" textgroup="{$textgroup-urn}" label="{$workTitle}"/>

};

declare function local:GreekWorks-index($start as xs:int) 
{
    let $GreekAuthors := doc('/db/spreadsheet_data/GreekAuthors.xml')
    return map:merge(
    for $row at $n in $GreekAuthors//row
    let $workTitle := normalize-space($row/WORK_TITLE)
    for $i at $m in tokenize($row/TLG_, ",")
    where not($i = ('n.a.', 'none', 'no', '', 'uncertain', 'various'))
    let $tlg-prefix := local:tlg-prefix(normalize-space($i))
    let $tokens := tokenize($tlg-prefix, '/.')
    let $textgroup := $tokens[1]
    let $work := $tokens[2]
    let $textgroup-urn := string-join(('urn', 'cts', 'greekLit', $textgroup), ':')
    let $ctsurn := string-join(($textgroup-urn, $work), '.')
    return
        map:entry($ctsurn, $start + $n + ($m - 1))
    )
};

(: Latin Works :)

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
    let $prefix := "urn:cts:latinLit:"
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

declare function local:LatinWorks($index as xs:int) {
    for $row at $n in doc('/db/spreadsheet_data/LatinAuthors.xml')//row
    let $ctsurn := local:ctsurn-of($row)
    let $label  := normalize-space($row/WORK_TITLE)
    let $phi_id := if (local:phi-id-of($row)) then local:phi-id-of($row) else ()
    let $stoa_id := if (local:stoa-id-of($row)) then local:stoa-id-of($row) else ()
    return
         <work n="{$index + $n}" ctsurn="{$ctsurn}" phi_id="{$phi_id}" stoa_id="{$stoa_id}" textgroup="{local:textgroup-of($ctsurn)}" label="{$label}"/>
};

declare function local:works() {
    let $greekworks := local:GreekWorks(0)
    let $latinworks := local:LatinWorks(count($greekworks))
    return ($greekworks union $latinworks)
};

declare function local:collated-Greek-authors-works() {
    for $row in doc('/db/spreadsheet_data/GreekAuthors.xml')//row
    (: generate author reference :)
    let $author-viaf := normalize-space($row/VIAF_URI)
    (: generate an entry for each TLG :)
    for $i in tokenize($row/TLG_, ",")
    where not($i = ('n.a.', 'none', 'no', '', 'uncertain', 'various'))
    let $tlg-prefix := local:tlg-prefix(normalize-space($i))
    let $tokens := tokenize($tlg-prefix, '/.')
    let $textgroup := $tokens[1]
    let $work := $tokens[2]
    let $textgroup-urn := string-join(('urn', 'cts', 'greekLit', $textgroup), ':')
    let $ctsurn := string-join(($textgroup-urn, $work), '.')
    return
        <work ctsurn="{$ctsurn}" author="{$author-viaf}"/>    
};


declare function local:collated-Latin-authors-works() {
    for $row in doc('/db/spreadsheet_data/LatinAuthors.xml')//row
    (: generate author reference :)
    let $author-viaf := normalize-space($row/VIAF_URI)
    let $ctsurn := local:ctsurn-of($row)
    return <work ctsurn="{$ctsurn}" author="{$author-viaf}"/>
};

(: Now for expressions & manifestations :)
declare function local:expressions() {
    for $ctsurn at $n in 
        distinct-values(collection('/db/working_mods')//mods:relatedItem[@otherType='expression']/mods:identifier[@type='ctsurn'])
    return 
        <expression n="{$n}" ctsurn="{normalize-space($ctsurn)}"/>

};

declare function local:manifestations() {
    for $mods at $n in collection('/db/working_mods')//mods:mods
    let $oclc := xs:string($mods/mods:identifier[@type='oclc'][1])
    return
        <manifestation n="{$n}" oclc="{$oclc}">
        {
         for $work in $mods//mods:relatedItem[@otherType='work']
         let $wid := xs:string($work/mods:identifier[@type='ctsurn'][1])
         return
             <work id="{$wid}">
             {
              for $expr in $work/mods:relatedItem[@otherType='expression']/mods:identifier[@type='ctsurn']
              return <expression id="{xs:string($expr)}"/>
             }
             </work>
        }
        </manifestation>
};

declare function local:assembled-data() {
    let $authors := local:authors()
    let $works := local:works()

    let $GreekCollation := local:collated-Greek-authors-works()
    let $LatinCollation := local:collated-Latin-authors-works()
    let $manifestations := local:manifestations()
    return
        <dataset>
            <authors>{ $authors }</authors>
            <works>{ $works }</works>
            <collations>{ $GreekCollation union $LatinCollation }</collations>
            <expressions>{ local:expressions() }</expressions>
            <manifestations>{ $manifestations }</manifestations>
        </dataset>
};

declare function local:author-rdf($author) {
    <rdf:Description 
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:owl="http://www.w3.org/2002/07/owl#"
        rdf:about="http://catalog.perseus.org/people/{$author/@n}">
        <rdf:type rdf:resource="http://erlangen-crm.org/efrbroo/F10_Person"/>
        <rdfs:label>{normalize-space(xs:string($author/@label))}</rdfs:label>
        <owl:sameAs rdf:resource="http://viaf.org/viaf/{$author/@viaf}"/>
    </rdf:Description>
};

declare function local:work-rdf($work) {
    <rdf:Description 
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:owl="http://www.w3.org/2002/07/owl#"
        xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
        rdf:about="http://catalog.perseus.org/works/{$work/@n}">
        <rdf:type rdf:resource="http://erlangen-crm.org/efrbroo/F1_Work"/>
        <rdfs:label>{normalize-space(xs:string($work/@label))}</rdfs:label>
        <efrbroo:P149_is_identified_by>{xs:string($work/@ctsurn)}</efrbroo:P149_is_identified_by>
    </rdf:Description>
};

declare function local:expression-rdf($expression) {
    <rdf:Description 
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:owl="http://www.w3.org/2002/07/owl#"
        xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
        rdf:about="http://catalog.perseus.org/expressions/{$expression/@n}">
        <rdf:type rdf:resource="http://erlangen-crm.org/efrbroo/F22_Self_Contained_Expression"/>
        <efrbroo:P149_is_identified_by>{xs:string($expression/@ctsurn)}</efrbroo:P149_is_identified_by>
    </rdf:Description>
};

declare function local:work-author-rdf($dataset) {
    for $work in $dataset/collations/work
    let $authornum := xs:string($dataset/authors/author[@viaf= $work/@author][1]/@n)
    let $worknum := xs:string($dataset/works/work[@ctsurn = $work/@ctsurn][1]/@n)
    return 
   <rdf:Description 
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:owl="http://www.w3.org/2002/07/owl#"
        xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
        rdf:about="http://catalog.perseus.org/works/{$worknum}">
        <efrbroo:R16i_initiated_by>
            <efrbroo:F27_Work_Conception>
                <efrbroo:P14_carried_out_by rdf:resource="http://catalog.perseus.org/people/{$authornum}"/>
            </efrbroo:F27_Work_Conception>
        </efrbroo:R16i_initiated_by>
    </rdf:Description>
};

declare function local:expression-work-rdf($dataset) {
    let $work-map := map:merge(
        for $work in $dataset/works/work 
        return map:entry(string($work/@ctsurn), string($work/@n)))
    let $expr-map := map:merge(
        for $expr in $dataset/expressions/expression 
        return map:entry(string($expr/@ctsurn), string($expr/@n)))
        
    for $work in $dataset/manifestations/manifestation/work
    let $work-num := $work-map(string($work/@id))
    return <work id="{$work/@id}" n="{$work-num}"/>

};

let $dataset := local:assembled-data()
return local:expression-work-rdf($dataset)