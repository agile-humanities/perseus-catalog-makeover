xquery version "3.1";


declare namespace mads = "http://www.loc.gov/mads/v2";
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace efrbroo = "http://erlangen-crm.org/efrbroo/";
declare namespace dcterms = "http://purl.org/dc/terms";


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
            error((), "not a cts urn: |" || $cts-urn || '|')
};

declare function local:valid-cts-urn-p($str as xs:string)
{
    let $regex := "^urn:cts:([^:]+):([^.]*)\.([^.]*)\.?(.*?)?$"
    let $result := fn:analyze-string($str, $regex)/fn:match
    return
        not(empty($result/fn:group[@nr = 1]) or empty($result/fn:group[@nr = 2]) or empty($result/fn:group[@nr = 3]))
};


declare function local:work($cts-object as element())
as xs:string
{
    xs:string($cts-object/fn:group[@nr = 3])
};

declare function local:edition($cts-object as element())
as xs:string
{
    xs:string($cts-object/fn:group[@nr = 4])
};


declare function local:namespace($cts-object as element())
as xs:string
{
    xs:string($cts-object/fn:group[@nr = 1])
};

declare function local:textgroup($cts-object as element())
as xs:string
{
    xs:string($cts-object/fn:group[@nr = 2])
};


declare function local:greek-authors($index as xs:int) {
    let $all-authors :=
    for $row in doc('/db/spreadsheet_data/GreekAuthors.xml')//row
    let $viaf := normalize-space($row/VIAF_URI)
    let $label := normalize-space($row/LC_or_VIAF_AUTHOR_NAME)
    group by $viaf
    order by $label[1]
    return
        <author
            viaf="{$viaf[1]}"
            label="{$label[1]}"/>
    for $a at $n in $all-authors
    order by $a/@label
    return
        <author
            n="{$index + $n}"
            viaf="{$a/@viaf}"
            label="{$a/@label}"/>
};

declare function local:latin-authors($index as xs:int) {
    let $all-authors :=
    for $row in doc('/db/spreadsheet_data/LatinAuthors.xml')//row
    let $viaf := normalize-space($row/VIAF_URI)
    let $label := normalize-space($row/LC_NAME_TITLE_or_VIAF_AUTHOR_NAME)
    group by $viaf
    order by $label[1]
    return
        <author
            viaf="{$viaf[1]}"
            label="{$label[1]}"/>
    for $a at $n in $all-authors
    order by $a/@label
    return
        <author
            n="{$index + $n}"
            viaf="{$a/@viaf}"
            label="{$a/@label}"/>
};

declare function local:authors() {
    let $greeks := local:greek-authors(0)
    let $latins := local:latin-authors(count($greeks))
    return
        ($greeks union $latins)
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
    let $tokens := tokenize($tlg-prefix, '\.')
    let $textgroup := $tokens[1]
    let $work := $tokens[2]
    let $textgroup-urn := string-join(('urn', 'cts', 'greekLit', $textgroup), ':')
    let $ctsurn := string-join(($textgroup-urn, $work), '.')
    return
        <work
            n="{$index + $n + ($m - 1)}"
            ctsurn="{$ctsurn}"
            tlg="{$i}"
            textgroup="{$textgroup-urn}"
            label="{$workTitle}"/>

};

declare function local:GreekWorks-index($start as xs:int)
{
    let $GreekAuthors := doc('/db/spreadsheet_data/GreekAuthors.xml')
    return
        map:merge(
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
    then
        $str
    else
        local:padleft(concat($padchar, $str), $padchar, $len)
};

declare function local:phi-id($idstring as xs:string) {
    let $tokens := tokenize($idstring, '\.')
    return
        if (count($tokens) = 2) then
            "phi" || local:padleft($tokens[1], '0', 4) || ".phi" || local:padleft($tokens[2], '0', 3)
        else
            "NNNNnnnnnn"
};

declare function local:stoa-id($idstring as xs:string) as xs:string
{
    string-join((tokenize($idstring, '-')), '.')
};

declare function local:phi-id-of($row) as xs:string?
{
    if ($row/PHI_ and not(empty($row/PHI_)) and not($row/PHI_/text() = "none"))
    then
        normalize-space($row/PHI_[1])
    else
        ()
};

declare function local:stoa-id-of($row) as xs:string?
{
    if ($row/STOA_ and not(empty($row/STOA_)) and not($row/STOA_/text() = "none"))
    then
        normalize-space($row/STOA_[1])
    else
        ()
};

declare function local:ctsurn-of($row as element())
as xs:string
{
    let $prefix := "urn:cts:latinLit:"
    return
        if ($row/PHI_ and not(empty($row/PHI_)) and not($row/PHI_/text() = "none"))
        then
            concat($prefix, local:phi-id(normalize-space($row/PHI_[1])))
        else
            if ($row/STOA_ and not(empty($row/STOA_)) and not($row/STOA_/text() = "none"))
            then
                concat($prefix, local:stoa-id(normalize-space($row/STOA_[1])))
            else
                "XXXXXXXXX"
};

declare function local:textgroup-of($ctsurn as xs:string) as xs:string?
{
    let $textgroup := tokenize(tokenize($ctsurn, ':')[4], '\.')[1]
    return
        if ($textgroup) then
            concat('urn:cts:latinLit:', $textgroup)
        else
            ()
};

declare function local:LatinWorks($index as xs:int) {
    for $row at $n in doc('/db/spreadsheet_data/LatinAuthors.xml')//row[not(empty(WORK_TITLE))]
    let $ctsurn := local:ctsurn-of($row)
    let $label := normalize-space($row/WORK_TITLE)
    let $phi_id := 
        if (local:phi-id-of($row)) then
            local:phi-id-of($row)
        else ()
    let $stoa_id := 
        if (local:stoa-id-of($row)) then
            local:stoa-id-of($row)
        else ()
    return
        <work
            n="{$index + $n}"
            ctsurn="{$ctsurn}"
            phi_id="{$phi_id}"
            stoa_id="{$stoa_id}"
            textgroup="{local:textgroup-of($ctsurn)}"
            label="{$label}"/>
};

declare function local:works() {
    let $greekworks := local:GreekWorks(0)
    let $latinworks := local:LatinWorks(count($greekworks))
    return
        ($greekworks union $latinworks)
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
        <work
            ctsurn="{$ctsurn}"
            author="{$author-viaf}"/>
};


declare function local:collated-Latin-authors-works() {
    for $row in doc('/db/spreadsheet_data/LatinAuthors.xml')//row
    (: generate author reference :)
    let $author-viaf := normalize-space($row/VIAF_URI)
    let $ctsurn := local:ctsurn-of($row)
    return
        <work
            ctsurn="{$ctsurn}"
            author="{$author-viaf}"/>
};

(: Now for expressions & manifestations :)
declare function local:expressions() {
    for $ctsurn at $n in
    distinct-values(collection('/db/working_mods')//mods:relatedItem[@otherType = 'expression']/mods:identifier[@type = 'ctsurn'])
    return
        <expression
            n="{$n}"
            ctsurn="{normalize-space($ctsurn)}"/>

};

declare function local:manifestations() {
    for $mods at $n in collection('/db/working_mods')//mods:mods
    let $oclc := xs:string($mods/mods:identifier[@type = 'oclc'][1])
    return
        <manifestation
            n="{$n}"
            oclc="{$oclc}">
            {
                for $work in $mods//mods:relatedItem[@otherType = 'work']
                let $wid := xs:string($work/mods:identifier[@type = 'ctsurn'][1])
                return
                    <work
                        id="{$wid}">
                        {
                            for $expr in $work/mods:relatedItem[@otherType = 'expression']/mods:identifier[@type = 'ctsurn']
                            return
                                <expression
                                    id="{xs:string($expr)}"/>
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
            <authors>{$authors}</authors>
            <works>{$works}</works>
            <collations>{$GreekCollation union $LatinCollation}</collations>
            <expressions>{local:expressions()}</expressions>
            <manifestations>{$manifestations}</manifestations>
        </dataset>
};

declare function local:author-rdf($author) {
    <F10_Person
        xmlns="http://erlangen-crm.org/efrbroo/"
                 xmlns:owl="http://www.w3.org/2002/07/owl#"
        rdf:about="http://catalog.perseus.org/people/{$author/@n}">
        <rdfs:label>{normalize-space(xs:string($author/@label))}</rdfs:label>
        <owl:sameAs rdf:resource="http://viaf.org/viaf/{$author/@viaf}"/>
    </F10_Person>
};

declare function local:work-rdf($work) {
    <F15_Complex_Work
        xmlns="http://erlangen-crm.org/efrbroo/"
        rdf:about="{xs:string($work/@ctsurn)}">
        <rdfs:label>{normalize-space(xs:string($work/@label))}</rdfs:label>
        <P149_is_identified_by>{xs:string($work/@ctsurn)}</P149_is_identified_by>
        <R10i_is_member_of rdf:resource="{$work/@textgroup}"/>
        { if ($work/@tlg) then
            <P149_is_identified_by>{xs:string($work/@tlg)}</P149_is_identified_by>
          else () }
        { if ($work/@phi) then
            <P149_is_identified_by>{xs:string($work/@phi)}</P149_is_identified_by>
          else () }
        { if ($work/@stoa) then
            <P149_is_identified_by>{xs:string($work/@stoa)}</P149_is_identified_by>
          else () }
          </F15_Complex_Work>
};

declare function local:expression-rdf($expression) {
    if (local:valid-cts-urn-p($expression/@ctsurn)) then
        let $ctsurn := local:object($expression/@ctsurn)
        let $workid := string-join((local:textgroup($ctsurn), local:work($ctsurn)), '.')
        let $workurn := string-join(('urn', 'cts', local:namespace($ctsurn), $workid), ':')
        return
        <F22_Self_Contained_Expression
            xmlns="http://erlangen-crm.org/efrbroo/"
            rdf:about="{$expression/@ctsurn}">
            <rdfs:label>{xs:string($expression/@ctsurn)}</rdfs:label>
            <P149_is_identified_by>{xs:string($expression/@ctsurn)}</P149_is_identified_by>
            <R9i_realises>
                <F1_Work>
                    <R10i_is_member_of
                        rdf:resource="{$workurn}"/>
                </F1_Work>
            </R9i_realises>
        </F22_Self_Contained_Expression>
     else ()
};

declare function local:w-a-collation($work) {
    <F15_Complex_Work
        xmlns="http://erlangen-crm.org/efrbroo/"
        rdf:about="{$work/@ctsurn}">
        <R16i_initiated_by>
            <F27_Work_Conception>
                <P14_carried_out_by
                    rdf:resource="http://www.viaf.org/viaf/{$work/@author}"/>
            </F27_Work_Conception>
        </R16i_initiated_by>
    </F15_Complex_Work>
};

declare function local:manifestation-rdf($manifestation) {
    <F3_Manifestation_Product_Type
        xmlns="http://erlangen-crm.org/efrbroo/"
        rdf:about="http://www.worldcat.org/{$manifestation/@oclc}">
        {
            for $work in $manifestation/work
            for $expr in $work/expression
            return
              <CLR6_should_carry>
               <F24_Publication_Expression>
                 <P165_incorporates rdf:resource="{$expr/@id}"/>
            </F24_Publication_Expression>
        </CLR6_should_carry>
        }
    </F3_Manifestation_Product_Type>
};

declare function local:main() {
let $dataset := local:assembled-data()
return 
<rdf:RDF xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
         xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
         xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:owl="http://www.w3.org/2002/07/owl#"
>
         { for $a in $dataset/authors/author return local:author-rdf($a) }
         { for $w in $dataset/works/work return local:work-rdf($w) }
         { for $w in $dataset/collations/work return local:w-a-collation($w) }
         { for $e in $dataset/expressions/expression return local:expression-rdf($e) }
         { for $m in $dataset/manifestations/manifestation return local:manifestation-rdf($m) }
         </rdf:RDF>
};

local:main()