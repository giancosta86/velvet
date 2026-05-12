use str
use ../../assertion
use ../../utils/output

fn should-have-prefix { |expected-prefix|
  var actual = (assertion:get-string-subject)

  assertion:enforce-string-argument $expected-prefix

  if (not (str:has-prefix $actual $expected-prefix)) {
    output:display-wrong 'Actual string' $actual

    output:display-wrong 'Expected prefix' $expected-prefix

    assertion:fail (src)
  }
}