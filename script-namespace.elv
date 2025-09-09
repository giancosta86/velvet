use path
use ./assertions
use ./describe-context

fn create-controller { |source-path|
  var absolute-path = (path:abs $source-path)
  var source-code = (slurp < $absolute-path)

  var total-tests = (num 0)
  var total-failed = (num 0)

  var root-context = (describe-context:create)
  var current-describe-context = $nil

  var first-exception = $nil

  fn virtual-src {
    put [
      &code=$source-code
      &is-file=$true
      &name=$absolute-path
    ]
  }

  fn virtual-use-mod { |requested-module|
    use-mod './tests/relative/beta'
  }

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

    set total-tests = (+ $total-tests 1)

    var test-outcome = ($current-describe-context[run-test] $test-title $block)

    if (not $test-outcome) {
      set total-failed = (+ $total-failed 1)

      #TODO! If the first exception is not set, set it based on the test outcome!
    }
  }

  var namespace = (ns [
    &src~=$virtual-src~
    &use-mod~=$virtual-use-mod~
    &describe~=$describe~
    &it~=$it~
    &assert~=$assertions:assert~
    &expect-crash~=$assertions:expect-crash~
    &fail-test~=$assertions:fail-test~
    &should-be~=$assertions:should-be~
  ])

  fn get-stats {
    put [
      &total=$total-tests
      &failed=$total-failed
      &passed=(- $total-tests $total-failed)
    ]
  }

  fn to-result-context {
    $root-context[to-result-context]
  }

  eval $source-code &ns=$namespace &on-end={ |final-namespace|
    set namespace = $final-namespace
  }

  put [
    &namespace=$namespace
    &get-stats=$get-stats~
    &to-result-context=$to-result-context~
  ]
}