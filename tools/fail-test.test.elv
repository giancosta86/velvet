use ./fail-test

var fail-test~ = $fail-test:fail-test~

>> 'Assertions: fail-test' {
  >> 'when raising a test failure' {
    fails {
      fail-test
    } |
      should-be 'TEST SET TO FAIL'
  }
}