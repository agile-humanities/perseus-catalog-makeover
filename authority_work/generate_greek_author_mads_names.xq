xquery version "3.0";
(:~
 : Extracts author data from Greek Authors spreadsheet.
 :
 : To use: establish an Oxygen transformation scenario
 : that links this xquery with GreekAuthors.xml
 :)
  

let $author_recs :=
    for $row in //row
    let $name := normalize-space($row/LC_or_VIAF_AUTHOR_NAME)
    let $viaf_uri := normalize-space($row/VIAF_URI)
    let $lc_id := normalize-space($row/LC__)
    group by $name
    order by $name
    return 
        if ($name[1]) then
        <mads xmlns="http://www.loc.gov/mads/v2">
        <authority>
        <name>
            <namePart>{ $name }</namePart>
        </name>
        </authority>
        { if ($viaf_uri[1] and not($viaf_uri = ('none'))) then
            <identifier type="viaf">{ $viaf_uri[1] }</identifier>
          else (),
          if ($lc_id[1] and not($lc_id = ('none'))) then
             <identifier type="lc">{ $lc_id[1] }</identifier>
          else () }
    </mads>
    else ()
    
return 
    <madsCollection  xmlns="http://www.loc.gov/mads/v2">
    { ($author_recs intersect $author_recs) }
    </madsCollection>