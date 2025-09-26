fn assert { |predicate|
  if (not $predicate) {
    fail 'Assertion failed!'
  }
}
