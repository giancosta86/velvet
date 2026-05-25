use str
use github.com/giancosta86/ethereal/v1/collection
use ../../assertion
use ../../output

fn should-not-contain-snippet { |snippet-lines|
  var subject = (assertion:get-string-subject)

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
