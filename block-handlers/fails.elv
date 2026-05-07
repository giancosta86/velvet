use github.com/giancosta86/ethereal/v1/exception
use ./throws

fn fails { |block|
  var exception = (throws:throws $block)

  var fail-content = (exception:get-fail-content $exception)

  if (eq $fail-content $nil) {
    fail $exception
  }

  put $fail-content
}