>> 'Exceptions' {
  >> 'handling and detection' {
    var message = DODO

    throws {
      fail $message
    } |
      get-fail-message |
      should-be $message
  }
}