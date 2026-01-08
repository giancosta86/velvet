>> 'Exceptions' {
  >> 'handling and detection' {
    var message = DODO

    throws {
      fail $message
    } |
      exception:get-fail-content |
      should-be $message
  }
}