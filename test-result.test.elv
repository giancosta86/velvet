use ./outcomes
use ./test-result

>> 'Test result'  {
  var output-lines = [Alpha Beta]
  var exception-lines = [(show ?(fail DODO))]

  >> 'creation' {
    >> 'success' {
      test-result:success $output-lines |
        should-be [
          &output-lines=$output-lines
          &outcome=$outcomes:passed
          &exception-lines=$nil
        ]
    }

    >> 'failure' {
      test-result:failure $output-lines $exception-lines |
        should-be [
          &output-lines=$output-lines
          &outcome=$outcomes:failed
          &exception-lines=$exception-lines
        ]
    }
  }

  >> 'simplification' {
    >> 'for passed test' {
      var source-test = (test-result:success $output-lines)

      test-result:simplify $source-test |
        should-be $source-test
    }

    >> 'for failed test' {
      test-result:failure $output-lines $exception-lines |
        test-result:simplify |
        should-be (
          test-result:failure $output-lines []
        )
    }
  }
}