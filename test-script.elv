use path
use re
use str
use ./assertions
use ./describe-context
use ./test-result

fn run { |script-path|
  var abs-script-path = (path:abs $script-path)
  var script-code = (slurp < $script-path)

  var root-context = (describe-context:create)
  var current-describe-context = $root-context

  fn update-exception-log { |exception-log|
    var lines = [(put $exception-log | to-lines)]

    var script-stack-lines = $lines[..-1]

    var eval-line = $lines[-1]

    var updated-eval-line = (
      re:replace '\[eval\s+\d+\]:(\d+?):(\d+).*?:' $abs-script-path':$1:$2:' $eval-line
    )

    str:join "\n" [$@script-stack-lines $updated-eval-line]
  }

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
    var exception-log = $test-result[exception-log]

    var updated-test-result

    if $exception-log {
      var updated-exception-log = (
        update-exception-log $exception-log
      )

      set updated-test-result = (
        assoc $test-result exception-log $updated-exception-log
      )
    } else {
      set updated-test-result = $test-result
    }

    $current-describe-context[add-test-result] $test-title $updated-test-result
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