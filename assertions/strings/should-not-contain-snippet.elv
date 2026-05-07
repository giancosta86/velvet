use str
use ../../assertion
use ../../utils/output

fn should-not-contain-snippet { |snippet-lines|
  var subject = (one)

  if (not (eq (kind-of $subject) string)) {
    fail 'The subject must be a string'
  }

  var unexpected-snippet = (str:join "\n" $snippet-lines)

  if (str:contains $subject $unexpected-snippet) {
    output:contrast [
      &red-description='Actual string'
      &red=$subject
      &green-description='Unexpected snippet'
      &green=$unexpected-snippet
      &show-diff=$true
    ]

    assertion:fail (src)
  }
}
