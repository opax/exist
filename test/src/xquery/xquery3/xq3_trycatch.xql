xquery version "3.0";
module namespace tc="http://exist-db.org/xquery/test/xq3_trycatch";

declare namespace test="http://exist-db.org/xquery/xqsuite";

declare namespace ns  = "urn:ns";
declare namespace ns2 = "urn:ns2";

declare
    %test:name("ignore errors in wrong namespace with matching prefix")
    %test:assertEquals('wildcard')
function tc:catch-with-matching-prefix-different-uri() {
  try {
      error(QName("urn:ns2", "ns:error"))
  } catch ns:error {
      'ns:error'
  } catch * {
      'wildcard'
  }
};

declare
    %test:name("catch a namespaced error with an arbitrary prefix")
    %test:assertEquals('ns:error')
function tc:catch-with-matching-uri-different-prefix() {
  try {
      error(QName("urn:ns", "some_prefix:error"))
  } catch ns:error {
      'ns:error'
  } catch * {
      'wildcard'
  }
};