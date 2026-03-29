use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/ethereal/v1/operator
use ./section

var empty = [
  &section=$section:empty
  &crashed-scripts=[&]
]

var merge~ = (
  fn merge-two { |left right|
    put [
      &section=(
        section:merge $left[section] $right[section]
      )
      &crashed-scripts=(
        map:merge $left[crashed-scripts] $right[crashed-scripts]
      )
    ]
  }

  operator:multi-value $empty $merge-two~
)