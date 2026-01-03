use ./fail-test
use ./throws

var fail-test~ = $fail-test:fail-test~

>> 'Assertions: fail-test' {
  >> 'when raising a test failure' {
    throws {
      fail-test
    } |
      get-fail-content |
      should-be 'TEST SET TO FAIL'
  }
}