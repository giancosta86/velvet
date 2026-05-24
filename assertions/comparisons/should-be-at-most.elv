use ./shared

fn should-be-at-most { |upper-bound|
  shared:run-comparison-assertion [
    &assertion-reference=(src)
    &raw-boundary=$upper-bound
    &range-template='(...; %s]'
    &predicate={ |less-than subject upper-bound|
      or ($less-than $subject $upper-bound) (eq $subject $upper-bound)
    }
  ]
}