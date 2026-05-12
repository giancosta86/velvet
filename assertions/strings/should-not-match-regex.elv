use re
use ../../assertion
use ../../utils/output

fn should-not-match-regex { |unexpected-pattern|
  var actual = (assertion:get-string-subject)

  assertion:enforce-string-argument $unexpected-pattern

  if (re:match $unexpected-pattern $actual) {
    output:display-wrong 'Actual string' $actual

    output:display-wrong 'Unexpected regex pattern' $unexpected-pattern

    assertion:fail (src)
  }
}