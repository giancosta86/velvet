use str
use ../../assertion
use ../../utils/output

fn should-contain-snippet { |snippet-lines|
  var subject = (one)

  if (not (eq (kind-of $subject) string)) {
    fail 'The subject must be a string'
  }

  var expected-snippet = (str:join "\n" $snippet-lines)

  if (not (str:contains $subject $expected-snippet)) {
    output:contrast [
      &red-description='Actual string'
      &red=$subject
      &green-description='Expected snippet'
      &green=$expected-snippet
      &show-diff=$true
    ]

    assertion:fail (src)
  }
}
