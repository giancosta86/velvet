use ./shared

fn should-be-less-than { |upper-bound|
  shared:run-comparison-assertion [
    &assertion-reference=(src)
    &raw-boundary=$upper-bound
    &range-template='(...; %s)'
    &predicate={ |less-than subject upper-bound|
      $less-than $subject $upper-bound
    }
  ]
}