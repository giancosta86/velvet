use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/map
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

fn merge { |@arguments|
  lang:get-inputs $arguments |
    seq:reduce $empty { |cumulated-result current-result|
      -merge-two $cumulated-result $current-result
    }
}