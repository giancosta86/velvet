use str
use ../../assertion
use ../../output

fn should-not-have-prefix { |unexpected-prefix|
  var actual = (assertion:get-string-subject)

  assertion:enforce-string-argument $unexpected-prefix

  if (str:has-prefix $actual $unexpected-prefix) {
    output:display-wrong 'Actual string' $actual

    output:display-wrong 'Unexpected prefix' $unexpected-prefix

    assertion:fail (src)
  }
}