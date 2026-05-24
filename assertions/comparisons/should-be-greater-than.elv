use ./shared

fn should-be-greater-than { |lower-bound|
  shared:run-comparison-assertion [
    &assertion-reference=(src)
    &raw-boundary=$lower-bound
    &range-template='(%s; ...)'
    &predicate={ |less-than subject lower-bound|
      not (
        or ($less-than $subject $lower-bound) (eq $subject $lower-bound)
      )
    }
  ]
}