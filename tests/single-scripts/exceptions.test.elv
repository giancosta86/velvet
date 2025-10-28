>> 'Exceptions' {
  >> 'handling and detection' {
    var message = DODO

    expect-throws {
      fail $message
    } |
      get-fail-message |
      should-be $message
  }
}