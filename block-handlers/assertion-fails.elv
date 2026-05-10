use str
use github.com/giancosta86/ethereal/v1/exception
use ../assertion
use ../utils/output
use ./throws

var throws~ = $throws:throws~

fn assertion-fails { |assertion-reference block|
  var expected-failure-message = (
    assertion:format-failure $assertion-reference
  )

  var exception = (
    throws $block
  )

  var failure-message = (exception:get-fail-content $exception)

  if (not-eq $failure-message $expected-failure-message) {
    show $exception

    if (
      or ^
        (not $failure-message) ^
        (not (str:has-prefix $failure-message $assertion:failure-prefix))
    ) {
      fail 'There was an exception, but not induced by an assertion'
    }

    var actual-assertion = $failure-message[(count $assertion:failure-prefix)..]

    var expected-assertion = (assertion:get-name $assertion-reference)

    output:contrast [
      &red-description='Actual assertion'
      &red=$actual-assertion
      &green-description='Expected assertion'
      &green=$expected-assertion
      &show-diff=$false
    ]

    fail 'Another assertion failed'
  }
}