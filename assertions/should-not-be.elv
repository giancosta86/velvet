use ../assertion
use ../utils/output

fn should-not-be { |&strict=$false unexpected|
  var actual = (one | assertion:get-input &strict=$strict)

  set unexpected = (assertion:get-input &strict=$strict $unexpected)

  if (eq $unexpected $actual) {
    output:display-wrong 'Unexpected value' $unexpected

    assertion:fail (src)
  }
}