use path
use ./assertions
use ./frame
use ./utils/exception

fn run { |script-path|
  var abs-script-path = (path:abs $script-path)
  var script-code = (slurp < $script-path)

  var root-frames = []
  var current-frame = $nil

  fn custom-src {
    put [
      &is-file=$true
      &name=$abs-script-path
      &code=$script-code
    ]
  }

  fn '>>' { |title block|
    var this-frame = (frame:create $abs-script-path $title)

    var parent-frame = $current-frame

    if $parent-frame {
      $parent-frame[add-sub-frame] $this-frame
    } else {
      set root-frames = [$@root-frames $this-frame]
    }

    tmp current-frame = $this-frame

    var block-result = (command:capture $block)

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

  all $root-frames | each { |root-frame|
    var frame-result = (root-frame[to-result])

    var is-section = (has-key $frame-result sub-sections)

    if $is-section {
      put $frame-result
    } else {
      put [
        &test-results=[&$root-frame[title]=$frame-result]
        &sub-sections=[]
      ]
    }
  } |
    section:merge
}