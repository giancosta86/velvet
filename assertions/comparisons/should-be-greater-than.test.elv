use ./test-shared

test-shared:run-comparison-tests [
  &'>>~'=$'>>~'
  &assertion-reference=(src)
  &status=[
    &subject-equal=fail
    &subject-greater=pass
    &subject-less=fail
  ]
]