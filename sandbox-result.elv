use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/ethereal/v1/operator
use github.com/giancosta86/ethereal/v1/seq
use ./section

var empty = [
  &section=$section:empty
  &crashed-scripts=[&]
]

fn -merge-two { |left right|
  put [
    &section=(
      put $left[section] $right[section] |
        section:merge
    )
    &crashed-scripts=(
      put $left[crashed-scripts] $right[crashed-scripts] |
        map:merge
    )
  ]
}

var merge~ = (operator:multi-value $empty $-merge-two~)