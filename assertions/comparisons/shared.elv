use ../../assertion
use ../../output

fn run-comparison-assertion { |settings|
  var assertion-reference = $settings[assertion-reference]
  var raw-boundary = $settings[raw-boundary]
  var range-template = $settings[range-template]
  var predicate = $settings[predicate]

  var subject = (one)

  var subject-kind = (kind-of $subject)

  var less-than boundary = (
    if (eq $subject-kind number) {
      put $'<~'
      num $raw-boundary
    } elif (eq $subject-kind string) {
      put $'<s~'
      to-string $raw-boundary
    } else {
      fail 'Unsupported comparison subject: '$subject-kind
    }
  )

  if (not ($predicate $less-than $subject $boundary)) {
    var expected-range = (
      printf $range-template $boundary
    )

    output:contrast [
      &red-description='Actual'
      &red=$subject
      &green-description='Expected range'
      &green=$expected-range
      &show-diff=$false
    ]

    assertion:fail $assertion-reference
  }
}