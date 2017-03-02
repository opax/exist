xquery version "3.0";

module namespace axes="http://exist-db.org/xquery/test/axes";

declare namespace test="http://exist-db.org/xquery/xqsuite";

declare variable $axes:NESTED_DIVS :=
    <body>
        <div>
            <head>1</head>
            <div>
                <head>2</head>
                <div>
                    <head>3</head>
                </div>
            </div>
            <div>
                <head>4</head>
                <div>
                    <head>5</head>
                </div>
                <div>
                    <head>6</head>
                    <div>
                        <head>7</head>
                    </div>
                </div>
            </div>
        </div>
    </body>;

declare 
    %test:setUp
function axes:setup() {
    xmldb:create-collection("/db", "axes-test"),
    xmldb:store("/db/axes-test", "test.xml", $axes:NESTED_DIVS)
};

declare 
    %test:tearDown
function axes:cleanup() {
    xmldb:remove("/db/axes-test")
};

(: ---------------------------------------------------------------
 : Descendant axis: check if nested elements are handled properly.
 : Wrong evaluation may lead to duplicate nodes being returned.
   --------------------------------------------------------------- :)

declare 
    %test:assertEquals(6, 6)
function axes:descendant-axis-nested() {
    let $node := doc("/db/axes-test/test.xml")/body
    return (
        count($node/descendant::div/descendant::div),
        count($node//div//div)
    )
};

declare 
    %test:assertEquals("<head>1</head>")
function axes:descendant-axis-except-nested1() {
    let $node := doc("/db/axes-test/test.xml")/body
    return
        ($node//div except $node//div//div)/head
};

declare 
    %test:assertEquals("<head>2</head>", "<head>4</head>")
function axes:descendant-axis-except-nested2() {
    let $node := doc("/db/axes-test/test.xml")/body/div
    return
        ($node//div except $node//div//div)/head
};

declare
%test:assertError("err:XPDY0002")
%test:name("expect error because variable declaration should not change context sequence")
function axes:context-self() {
util:eval("
        declare variable $foo := 123;

        .
    ")
};

declare
%test:assertError("err:XPDY0002")
%test:name("expect error because preceding let should not change context sequence")
function axes:context-let-self() {
util:eval("
        let $a := 123
        let $b := .
        return
            $b
    ")
};

declare
%test:assertEquals("true")
%test:name("preceding-sibling axis should be empty on attribute node")
function axes:preceding-sibling-on-attr() {
    let $d := <a b="c"/>
    return empty($d/@b/preceding-sibling::*)
};

declare
%test:assertEquals("true")
%test:name("following-sibling axis should be empty on attribute node")
function axes:preceding-sibling-on-attr() {
  let $d := <a b="c"/>
  return empty($d/@b/following-sibling::*)
};

declare
%test:assertEquals("<prec/>")
%test:name("preceding axis should work just as on parent element")
function axes:preceding-on-attr() {
  let $d := <top><prec/><a b="c"/><foll/></top>
  return empty($d//a/@b/preceding::*)
};

declare
%test:assertEquals("<foll/>")
%test:name("following axis should work just as on parent element")
function axes:preceding-on-attr() {
  let $d := <top><prec/><a b="c"/><foll/></top>
  return empty($d//a/@b/following::*)
};
