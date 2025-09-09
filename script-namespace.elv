use path
use ./assertions
use ./describe-context
use ./outcomes

fn create-controller { |source-path|
  var total-passed = (num 0)
  var total-failed = (num 0)

  var root-context = (describe-context:create)
  var current-describe-context = $nil

  var first-exception = $nil

  fn describe { |describe-title block|
    var sub-context = (
      $current-describe-context[ensure-sub-context] $describe-title
    )

    tmp current-describe-context = $sub-context

    $block
  }

  fn it { |test-title block|
    #TODO! Should this constraint be removed?
    if (not $current-describe-context) {
      fail 'Tests must be declared via "it" blocks within a hierarchy of "declare" blocks!'
    }

    var test-outcome = ($current-describe-context[run-test] $test-title $block)

    var outcome-handler = [
      $outcomes:passed={
        set total-passed = (+ $total-passed 1)
      }

      $outcomes:failed={
        set total-failed = (+ $total-failed 1)

        if (eq $first-exception $nil) {
          set first-exception = $test-outcome[status]
        }
      }
    ][$test-outcome]
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
      &failed=$total-failed
      &passed=$total-passed
      &total=(+ $total-passed $total-failed)
    ]
  }

  fn to-result-context {
    $root-context[to-result-context]
  }

  fn get-first-exception {
    put $first-exception
  }

  put [
    &namespace=$namespace
    &get-stats=$get-stats~
    &to-result-context=$to-result-context~
    &get-first-exception=$get-first-exception~
  ]
}