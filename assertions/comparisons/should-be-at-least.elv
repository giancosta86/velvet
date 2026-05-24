use ./shared

fn should-be-at-least { |lower-bound|
  shared:run-comparison-assertion [
    &assertion-reference=(src)
    &raw-boundary=$lower-bound
    &range-template='[%s; ...)'
    &predicate={ |less-than subject lower-bound|
      not (
        $less-than $subject $lower-bound
      )
    }
  ]
}