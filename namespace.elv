use path
use ./assertions
use ./describe-context

fn create { |&fail-fast=$false|
  var current-source-path

  var total-tests = 0
  var total-failed = 0

  var root-describe-contexts = [&]
  var current-describe-context = $nil

  fn set-current-source-path { |path|
    set current-source-path = (path:abs $path)
  }

  fn virtual-src {
    put [
      &code="src\n"
      &is-file=$true
      &name=$current-source-path
    ]
  }

  fn describe { |describe-title block|
    var coming-describe-context = (
      if $current-describe-context {
        $current-describe-context[ensure-sub-context] $describe-title
      } else {
        var ensure-result = (
          describe-context:ensure-in-map $root-describe-contexts $describe-title { describe-context:create-root $describe-title }
        )

        set root-describe-contexts = $ensure-result[updated-map]

        put $ensure-result[context]
      }
    )

    tmp current-describe-context = $coming-describe-context

    $block
  }

  fn it { |test-title block|
    if (not $current-describe-context) {
      fail 'Tests must be declared via "it" blocks within a hierarchy of "declare" blocks!'
    }

    set total-tests = (+ $total-tests 1)

    var test-outcome = ($current-describe-context[run-test] $test-title $block)

    if (not $test-outcome) {
      set total-failed = (+ $total-failed 1)

      if $fail-fast {
        fail $test-outcome
      }
    }
  }

  fn fail-test {
    fail 'TEST SET TO FAIL'
  }

  var namespace = (ns [
    &src~=$virtual-src~
    &describe~=$describe~
    &it~=$it~
    &fail-test~=$fail-test~
    &should-be~=$assertions:should-be~
    &expect-crash~=$assertions:expect-crash~
    &expect-log~=$assertions:expect-log~
  ])

  fn get-stats {
    put [
      &is-ok=(== $total-failed 0)
      &total-tests=$total-tests
      &total-failed=$total-failed
      &total-passed=(- $total-tests $total-failed)
    ]
  }

  fn get-outcome-map {
    describe-context:get-outcome-map $root-describe-contexts
  }

  put [
    &namespace=$namespace
    &get-stats=$get-stats~
    &get-outcome-map=$get-outcome-map~
    &set-current-source-path=$set-current-source-path~
  ]
}