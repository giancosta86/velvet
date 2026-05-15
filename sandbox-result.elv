use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/ethereal/v1/operator
use ./section

fn create { |@arguments|
  var section exception-lines-by-script = (
    all $arguments |
      lang:ensure-put &min-values=2
  )

  put [
    &section=(
      coalesce $section $section:empty
    )
    &exception-lines-by-script=(
      coalesce $exception-lines-by-script [&]
    )
  ]
}

var empty = (create)

var merge~ = (
  fn merge-two { |left right|
    create (
      section:merge $left[section] $right[section]
    ) (
      map:merge $left[exception-lines-by-script] $right[exception-lines-by-script]
    )
  }

  operator:multi-value $empty $merge-two~
)