use ./test-shared

test-shared:run-comparison-tests [
  &'>>~'=$'>>~'
  &assertion-reference=(src)
  &status=[
    &subject-equal=fail
    &subject-greater=fail
    &subject-less=pass
  ]
]