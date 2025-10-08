use path
use ./assertions
use ./describe-context

fn run { |script-path|
  var abs-script-path = (path:abs $script-path)
  var script-code = (slurp < $script-path)

  var root-context = (describe-context:create)
  var current-describe-context = $root-context

  fn custom-src {
    put [
      &is-file=$true
      &name=$abs-script-path
      &code=$script-code
    ]
  }

  fn describe { |context-title block|
    var sub-context = (
      $current-describe-context[ensure-sub-context] $context-title
    )

    tmp current-describe-context = $sub-context

    $block | only-bytes
  }

  fn it { |test-title block|
    $current-describe-context[run-test] $test-title $block |
      only-bytes
  }

  var namespace = (ns [
    &src~=$custom-src~
    &describe~=$describe~
    &it~=$it~
    &expect-crash~=$assertions:expect-crash~
    &fail-test~=$assertions:fail-test~
    &should-be~=$assertions:should-be~
    &should-not-be~=$assertions:should-not-be~
  ])

  tmp pwd = (path:dir $abs-script-path)
  eval &ns=$namespace $script-code

  $root-context[to-result]
}