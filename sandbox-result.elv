use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/ethereal/v1/operator
use ./exception-lines
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

fn from-section { |@arguments|
  var section = (lang:get-single-input $arguments)

  create $section
}

fn from-exception { |script-path exception|
  var exception-lines = [(
    show $exception |
      exception-lines:trim-clockwork-stack |
      exception-lines:replace-bottom-eval $script-path
  )]

  create $section:empty [
    &$script-path=$exception-lines
  ]
}

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