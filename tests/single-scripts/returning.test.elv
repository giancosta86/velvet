>> 'Returning from a test' {
  >> 'should work' {
    echo Alpha
    echo Beta >&2
    put 90

    return

    echo Never printed
  }
}