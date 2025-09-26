fn assert { |predicate|
  if (not $predicate) {
    fail 'ASSERTION FAILED!'
  }
}
