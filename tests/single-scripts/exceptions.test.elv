>> 'Exceptions' {
  >> 'handling and detection' {
    var message = DODO

    throws {
      fail $message
    } |
      get-fail-content |
      should-be $message
  }
}