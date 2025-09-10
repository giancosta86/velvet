use path
use ./assertions
use ./describe-context
use ./outcomes

fn create-controller {
  var passed = (num 0)
  var failed = (num 0)

  var root-context = (describe-context:create)
  var current-describe-context = $root-context

  var first-exception = $nil

  fn describe { |describe-title block|
    var sub-context = (
      $current-describe-context[ensure-sub-context] $describe-title
    )

    tmp current-describe-context = $sub-context

    $block
  }

  fn it { |test-title block|
    if (eq $current-describe-context $root-context) {
      fail 'Tests must be declared via "it" blocks within a hierarchy of "declare" blocks!'
    }

    var test-result = ($current-describe-context[run-test] $test-title $block)

    pprint $test-result >&2

    [
      &$outcomes:passed={
        set passed = (+ $passed 1)
      }

      &$outcomes:failed={
        set failed = (+ $failed 1)

        if (eq $first-exception $nil) {
          set first-exception = $test-result[status]
        }
      }
    ][$test-result[outcome]]
  }

  var namespace = (ns [
    &describe~=$describe~
    &it~=$it~
    &assert~=$assertions:assert~
    &expect-crash~=$assertions:expect-crash~
    &fail-test~=$assertions:fail-test~
    &should-be~=$assertions:should-be~
  ])

  fn get-stats {
    put [
      &failed=$failed
      &passed=$passed
      &total=(+ $passed $failed)
    ]
  }

  fn to-result {
    $root-context[to-result]
  }

  fn get-first-exception {
    put $first-exception
  }

  put [
    &namespace=$namespace
    &get-stats=$get-stats~
    &to-result=$to-result~
    &get-first-exception=$get-first-exception~
  ]
}