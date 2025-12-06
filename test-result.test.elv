use ./outcomes
use ./test-result

>> 'Test result simplification' {
  >> 'for passing test' {
    test-result:simplify [
      &output="Lorem ipsum\n"
      &outcome=$outcomes:passed
      &exception-log=$nil
    ] |
      should-be [
        &output="Lorem ipsum\n"
        &outcome=$outcomes:passed
      ]
  }

  >> 'for failing test' {
    test-result:simplify [
      &output="Lorem ipsum\n"
      &outcome=$outcomes:failed
      &exception-log=(show ?(fail DODO) | slurp)
    ] |
      should-be [
        &output="Lorem ipsum\n"
        &outcome=$outcomes:failed
      ]
  }
}