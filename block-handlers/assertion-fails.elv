use str
use github.com/giancosta86/ethereal/v1/exception
use ../assertion
use ../utils/output
use ./throws

var throws~ = $throws:throws~

fn assertion-fails { |assertion block|
  var expected-failure-message = (
    assertion:format-failure $assertion
  )

  var exception = (
    throws $block
  )

  var failure-message = (exception:get-fail-content $exception)

  if (not-eq $failure-message $expected-failure-message) {
    show $exception

    if (
      not (str:has-prefix $failure-message $assertion:failure-prefix)
    ) {
      fail 'There was an exception, but not induced by an assertion'
    }

    var actual-assertion = $failure-message[(count $assertion:failure-prefix)..]

    output:contrast [
      &red-description='Expected assertion'
      &red=$assertion
      &green-description='Actual assertion'
      &green=$actual-assertion
      &show-diff=$false
    ]

    fail 'Another assertion failed'
  }
}