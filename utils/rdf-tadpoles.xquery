declare namespace mods="http://www.loc.gov/mods/v3";
(:~
 : Constructs RDF expressions from MODS.
 :
 : Process of derivation:
 : 
 :)


for $book in //mods:mods
let $oclc_id := xs:string($book/mods:identifier[@type='oclc'])
let $book_label := xs:string($book/mods:titleInfo[1]/mods:title)

return
    <book label="{$book_label}" oclc="{$oclc_id}">
    {
        for $work in $book//mods:relatedItem[@otherType='work']
        let $work_label := xs:string($work/@displayLabel)
        let $id := xs:string($work/mods:identifier[@type='ctsurn'])
        return
            <work label="{$work_label}" id="{$id}">
            {
             for $expression in $work/mods:relatedItem[@otherType='expression']
             let $expression_label := xs:string($expression/@displayLabel)
             let $e_id := xs:string($expression/mods:identifier[@type='ctsurn'])
             return
                <expression label="{$expression_label}" id="{$e_id}"/>
            }
            </work>
    }
    </book>
