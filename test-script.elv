use path
use ./assertions
use ./describe-context
use ./outcomes

fn run { |script-path|
  var passed = (num 0)
  var failed = (num 0)

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

    var test-result = ($current-describe-context[run-test] $test-title $block)

    [
      &$outcomes:passed={
        set passed = (+ $passed 1)
      }

      &$outcomes:failed={
        set failed = (+ $failed 1)
      }
    ][$test-result[outcome]]
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

  var stats = [
    &failed=$failed
    &passed=$passed
    &total=(+ $passed $failed)
  ]

  var describe-result = ($root-context[to-result])

  put [
    &stats=$stats
    &describe-result=$describe-result
  ]
}