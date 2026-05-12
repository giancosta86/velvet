use str
use ../../assertion
use ../../utils/output

fn should-have-suffix { |expected-suffix|
  var actual = (assertion:get-string-subject)

  assertion:enforce-string-argument $expected-suffix

  if (not (str:has-suffix $actual $expected-suffix)) {
    output:display-wrong 'Actual string' $actual

    output:display-wrong 'Expected suffix' $expected-suffix

    assertion:fail (src)
  }
}