use re
use ../../assertion
use ../../output

fn should-match-regex { |expected-pattern|
  var actual = (assertion:get-string-subject)

  assertion:enforce-string-argument $expected-pattern

  if (not (re:match $expected-pattern $actual)) {
    output:display-wrong 'Actual string' $actual

    output:display-wrong 'Expected regex pattern' $expected-pattern

    assertion:fail (src)
  }
}