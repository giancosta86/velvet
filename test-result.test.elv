use ./outcomes
use ./test-result

>> 'Test result'  {
  var output-lines = [Alpha Beta]
  var exception = ?(fail DODO)

  >> 'success creation' {
    test-result:success $output-lines |
      should-be [
        &output-lines=$output-lines
        &outcome=$outcomes:passed
        &exception=$nil
      ]
  }

  >> 'failure creation' {
    test-result:failure $output-lines $exception |
      should-be [
        &output-lines=$output-lines
        &outcome=$outcomes:failed
        &exception=$exception
      ]
  }

  >> 'simplification' {
    >> 'for passed test' {
      test-result:simplify (test-result:success $output-lines) |
        should-be [
          &output-lines=$output-lines
          &outcome=$outcomes:passed
        ]
    }

    >> 'for failed test' {
      test-result:failure $output-lines $exception |
        test-result:simplify |
        should-be [
          &output-lines=$output-lines
          &outcome=$outcomes:failed
        ]
    }
  }
}