use path
use re
use str
use ./assertions
use ./describe-context
use ./test-result
use ./utils/exception

fn run { |script-path|
  var abs-script-path = (path:abs $script-path)
  var script-code = (slurp < $script-path)

  var current-frame = $nil
  var root-frames = []

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

  fn '>>' { |title block|
    var this-frame = (frame:create $title)

    var parent-frame = $current-frame

    if $parent-frame {
      $parent-frame[add-sub-frame] $this-frame
    } else {
      set root-frames = [$@root-frames $this-frame]
    }

    #TODO! Try to replace this with just tmp!
    set current-frame = $this-frame
    defer { set current-frame = $parent-frame }

    var block-result = (command:capture $block)

    var updated-block-result = (
      update-exception-log $block-result[exception-log] |
        assoc $block-result exception-log (all)
    )

    $current-frame[set-block-result] $block-result
  }

  var namespace = (ns [
    &src~=$custom-src~
    &'>>'~=$'>>~'
    &expect-throws~=$exception:expect-throws~
    &fail-test~=$assertions:fail-test~
    &should-be~=$assertions:should-be~
    &should-not-be~=$assertions:should-not-be~
  ])

  tmp pwd = (path:dir $abs-script-path)
  eval &ns=$namespace $script-code | only-bytes

  $root-context[to-result]
}