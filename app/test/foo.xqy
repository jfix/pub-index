xquery version "1.0-ml";
module namespace test = "http://github.com/robwhitby/xray/test";
import module namespace assert = "http://github.com/robwhitby/xray/assertions" at "/xray/src/assertions.xqy";

declare function node-should-equal-foo ()
{
    let $node := <foo/>
    return assert:equal($node, <foo/>)
};

(: another stupid test :)
declare function string-equality-example ()
{
  let $foo := "foo"
  return assert:equal($foo, "foo")
};