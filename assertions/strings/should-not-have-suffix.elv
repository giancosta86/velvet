use str
use ../../assertion
use ../../utils/output

fn should-not-have-suffix { |unexpected-suffix|
  var actual = (assertion:get-string-subject)

  assertion:enforce-string-argument $unexpected-suffix

  if (str:has-suffix $actual $unexpected-suffix) {
    output:display-wrong 'Actual string' $actual

    output:display-wrong 'Unexpected suffix' $unexpected-suffix

    assertion:fail (src)
  }
}