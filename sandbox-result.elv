use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/ethereal/v1/operator
use ./section

fn create { |@arguments|
  var section crashed-scripts = (
    all $arguments |
      lang:ensure-put &min-values=2
  )

  put [
    &section=(
      coalesce $section $section:empty
    )
    &crashed-scripts=(
      coalesce $crashed-scripts [&]
    )
  ]
}

var empty = (create)

var merge~ = (
  fn merge-two { |left right|
    create (
      section:merge $left[section] $right[section]
    ) (
      map:merge $left[crashed-scripts] $right[crashed-scripts]
    )
  }

  operator:multi-value $empty $merge-two~
)