xquery version "3.1";
(: This is a really bad script to transform texts from the
Folger Digital Texts collection (source: TEI Simple) to
the Dracor specific format to utilize the network analysis
pipeline. It adds a tei:particDesc and crawls some data from
wikidata.
@version 1.0
@author Mathias Göbel :)

import module namespace functx="http://www.functx.com";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(:~
 : prepares a sparql query for the date of first printed publication
 : and queries wikidata
:)
declare function local:p577($Q)
as xs:string {
    let $sparql := "SELECT ?date WHERE { wd:" || $Q || " p:P577 ?x. ?x ps:P577 ?date. }"
return
    local:wd-request($sparql)
};

(:~
 : prepares a sparql query for the date of creation/inception
 : and queries wikidata
:)
declare function local:p571($Q)
as xs:string {
    let $sparql := "SELECT ?early ?late WHERE { wd:" || $Q || " p:P571 ?x. ?x pq:P1319 ?early; pq:P1326 ?late. }"
    let $step1 := local:wd-request($sparql)
    return
        if($step1 = "")
        then $step1
        else
            local:p571-step2($Q)
};

(:~
 : prepares a more specific sparql query for the date of creation/inception
 : and queries wikidata. wikidata offers multiple fileds for this case…
:)
declare function local:p571-step2($Q)
as xs:string {
    let $sparql := "SELECT ?date WHERE { wd:" || $Q || " p:P571 ?x. ?x ps:P571 ?date. }"
    return
        local:wd-request($sparql)
};

(:~
 : sends a request to wikidata :)
declare function local:wd-request($SPARQL) {
    let $url := "https://query.wikidata.org/sparql?query="
    || encode-for-uri($SPARQL)
    return
        httpclient:get($url, false(), ())//*:literal/number(substring(., 1, 4))
        => max() => string()
};

(:~ prepares a tei:date element with given type and value in @when
:)
declare function local:date($type as xs:string, $when as xs:string)
as element(tei:date)? {
switch ($when)
    case "" return <tei:date type="{$type}"/>
    case "NaN" return <tei:date type="{$type}"/>
    default return
        <tei:date type="{$type}" when="{$when}"/>
};

let $wikidataMap as map(*):= map{
    "hamlet.xml": "Q41567",
    "king-john.xml":"Q661222",
    "antony-and-cleopatra.xml":"Q606830",
    "love-s-labor-s-lost.xml":"Q128610",
    "henry-vi-part-2.xml":"Q1236216",
    "henry-viii.xml":"Q672059",
    "the-taming-of-the-shrew.xml":"Q332387",
    "a-midsummer-night-s-dream.xml":"Q104871",
    "henry-v.xml":"Q495954",
    "henry-iv-part-i.xml":"Q631855",
    "macbeth.xml":"Q130283",
    "two-gentlemen-of-verona.xml":"Q232042",
    "henry-vi-part-3.xml":"Q1241754",
    "henry-iv-part-ii.xml":"Q1232349",
    "titus-andronicus.xml":"Q272169",
    "richard-iii.xml":"Q652011",
    "richard-ii.xml":"Q649562",
    "the-tempest.xml":"Q86440",
    "the-merchant-of-venice.xml":"Q206400",
    "troilus-and-cressida.xml":"Q183304",
    "king-lear.xml":"Q181598",
    "as-you-like-it.xml":"Q237572",
    "the-comedy-of-errors.xml":"Q506505",
    "henry-vi-part-1.xml":"Q643236",
    "much-ado-about-nothing.xml":"Q130851",
    "all-s-well-that-ends-well.xml":"Q506865",
    "twelfth-night.xml":"Q221211",
    "romeo-and-juliet.xml":"Q83186",
    "the-merry-wives-of-windsor.xml":"Q844836",
    "measure-for-measure.xml":"Q665446",
    "pericles.xml":"Q584729",
    "the-winter-s-tale.xml":"Q743194",
    "julius-caesar.xml":"Q215750",
    "coriolanus.xml":"Q463126",
    "timon-of-athens.xml":"Q284641",
    "othello.xml":"Q26833",
    "cymbeline.xml":"Q730212"
}

let $shakedracor := "/db/shakedracor"
(: cleanup :)
let $cleanup :=
    if(xmldb:collection-available($shakedracor))
    then xmldb:remove($shakedracor)
    else ()
let $create-collection := xmldb:create-collection("/db", "shakedracor")
let $teis := collection("/db/folger")//tei:TEI

for $tei in $teis
(: prepare new file :)
let $filename := (($tei//tei:title)[1]/string())
    => lower-case() => replace("\W", "-") => replace("--", "-") => concat(".xml")
let $newfile := xmldb:store($shakedracor, $filename, $tei)
let $newdoc := doc($newfile)
let $whos := $tei//tei:sp/tokenize(replace(@who, "#", ""), "\s")
let $persons :=
    for $who in $whos => distinct-values()

    (: clean old data :)
    let $sameAs := attribute sameAs { "#" || $who }
    let $update := update insert $sameAs into $newdoc//tei:castItem[@xml:id = $who]
    let $update := update delete $newdoc//tei:castItem[@xml:id = $who]/@xml:id

    let $castItem := $tei//tei:castItem[@xml:id = $who]
    let $name :=
        if($castItem[.//tei:name])
        then $castItem//tei:name/string()
        else string($castItem/parent::tei:castGroup/tei:head)
    let $name := if(not(string-join($name) = "")) then $name else string-join($castItem/text()) => normalize-space()
    let $name := if(not(string-join($name) = "")) then $name else $who

    return
        if( count($who) ne count($castItem) )
        then error(QName("error", "nonmatch"), "got not a castItem for every instance from @who")
        else
            <tei:person xml:id="{$who}">
                {for $persName in $name
                return
                    <tei:persName>{$name}</tei:persName>
                }
            </tei:person>
let $particDesc :=
    <tei:particDesc>
        <tei:listPerson>{$persons}</tei:listPerson>
    </tei:particDesc>

let $wikidata-idno := <tei:idno type="wikidata" xml:base="https://www.wikidata.org/wiki/">{$wikidataMap($filename)}</tei:idno>
let $bibl := <bibl xmlns="http://www.tei-c.org/ns/1.0" type="originalSource">
            {local:date("print",    local:p577($wikidataMap($filename)))}
            <date type="premiere"/>
            {local:date("written",  local:p571($wikidataMap($filename)))}
        </bibl>

let $author-key := attribute key {"Wikidata:Q692"}

return
    (update insert $particDesc into $newdoc//tei:profileDesc,
    update insert $wikidata-idno into ($newdoc//tei:publicationStmt)[1],
    update insert $bibl into $newdoc//tei:sourceDesc,
    update insert $author-key into ($newdoc//tei:author)[1],
    let $ns-fix := $newdoc => functx:change-element-ns-deep("http://www.tei-c.org/ns/1.0", "")
    return
        xmldb:store($shakedracor, $filename, $ns-fix),
    process:execute(("notify-send", $filename), ())
),
process:execute(("notify-send", "done"), ())
