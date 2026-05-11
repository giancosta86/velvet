use str
use github.com/giancosta86/ethereal/v1/collection
use ../../assertion
use ../../utils/output

fn should-not-contain-snippet { |snippet-lines|
  var subject = (one)

  if (not (eq (kind-of $subject) string)) {
    fail 'The subject must be a string'
  }

  var unexpected-snippet = (
    collection:to-list $snippet-lines |
      str:join "\n" (all)
  )

  if (str:contains $subject $unexpected-snippet) {
    output:display-wrong 'Actual string' $subject

    output:display-wrong 'Unexpected snippet' $unexpected-snippet

    assertion:fail (src)
  }
}
