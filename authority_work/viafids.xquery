xquery version "3.0";

declare variable $rows := doc('file:/Users/cwulfman/repos/github/agile-humanities/perseus-catalog-makeover/authority_work/LatinAuthors.xml')//row ;
(:there are 3281 rows:)
declare function local:authors() {
    $rows/LC_NAME_TITLE_or_VIAF_AUTHOR_NAME
};

declare function local:viafids() {
    let $viaf_uris := for $i in $rows/VIAF_URI return normalize-space($i)
    let $viaf_uris := distinct-values($viaf_uris)
    for $id in $viaf_uris 
    where not($id = ('none', 'nr95-27995', 'nr98-028467', '' ))
    order by $id
    return $id
};


local:viafids()
