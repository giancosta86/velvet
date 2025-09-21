use path
use ./assertions
use ./describe-context
use ./outcomes

fn run { |script-path|
  var abs-script-path = (path:abs $script-path)
  var script-code = (slurp < $script-path)

  var root-context = (describe-context:create)
  var current-describe-context = $root-context

  fn virtual-src {
    put [
      &is-file=$true
      &name=$abs-script-path
      &code=$script-code
    ]
  }

  fn describe { |describe-title block|
    var sub-context = (
      $current-describe-context[ensure-sub-context] $describe-title
    )

    tmp current-describe-context = $sub-context

    $block | only-bytes
  }

  fn it { |test-title block|
    if (eq $current-describe-context $root-context) {
      fail 'Tests must be declared via "it" blocks within a hierarchy of "declare" blocks!'
    }

    $current-describe-context[run-test] $test-title $block
  }

  var namespace = (ns [
    &src~=$virtual-src~
    &describe~=$describe~
    &it~=$it~
    &assert~=$assertions:assert~
    &expect-crash~=$assertions:expect-crash~
    &fail-test~=$assertions:fail-test~
    &should-be~=$assertions:should-be~
  ])

  eval &ns=$namespace $script-code

  $root-context[to-result]
}