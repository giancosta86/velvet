use path
use ./assertions
use ./describe-context
use ./test-result

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
    var test-result = (test-result:from-block $block)

    $current-describe-context[add-test-result] $test-title $test-result
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
  eval &ns=$namespace $script-code | only-bytes

  $root-context[to-result]
}