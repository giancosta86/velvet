use ./outcomes
use ./test-result

>> 'Test result'  {
  var output-lines = [Alpha Beta]
  var exception-lines = [(show ?(fail DODO))]

  >> 'success creation' {
    test-result:success $output-lines |
      should-be [
        &output-lines=$output-lines
        &outcome=$outcomes:passed
        &exception-lines=$nil
      ]
  }

  >> 'failure creation' {
    test-result:failure $output-lines $exception-lines |
      should-be [
        &output-lines=$output-lines
        &outcome=$outcomes:failed
        &exception-lines=$exception-lines
      ]
  }
}