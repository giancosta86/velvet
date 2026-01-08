use ./throws

var throws~ = $throws:throws~

>> 'Expecting an exception' {
  >> 'when no exception is thrown' {
    try {
      throws { }

      fail 'No exception was thrown by the expectation!'
    } catch e {
      exception:get-fail-content $e |
        should-be 'The given code block did not fail!'
    }
  }

  >> 'when there is an exception' {
    throws {
      fail DODO
    } |
      exception:get-fail-content |
      should-be DODO
  }

  >> 'in a pipeline, without arguments' {
    throws {
      fail CIOP
    } |
      exception:get-fail-content |
      should-be CIOP
  }
}