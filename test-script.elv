use path
use str
use ./assertions
use ./section
use ./test-script-frame
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
    var this-frame = (test-script-frame:create $abs-script-path $title)

    var parent-frame = $current-frame

    if $parent-frame {
      $parent-frame[add-sub-frame] $this-frame
    } else {
      set root-frames = [$@root-frames $this-frame]
    }

    tmp current-frame = $this-frame

    $current-frame[run-block] $block
  }

  fn gather-section {
    all $root-frames | each { |root-frame|
      var frame-title = $root-frame[title]

      var frame-artifact = ($root-frame[to-artifact])

      if (section:is-section $frame-artifact) {
        put [
          &test-results=[&]
          &sub-sections=[
            &$frame-title=$frame-artifact
          ]
        ]
      } else {
        put [
          &test-results=[
            &$frame-title=$frame-artifact
          ]
          &sub-sections=[&]
        ]
      }
    } |
      section:merge
  }

  var namespace = (ns [
    &src~=$custom-src~
    &'>>'~=$'>>~'
    &throws~=$exception:throws~
    &fail-test~=$assertions:fail-test~
    &get-fail-content~=$exception:get-fail-content~
    &should-be~=$assertions:should-be~
    &should-not-be~=$assertions:should-not-be~
  ])

  tmp pwd = (path:dir $abs-script-path)
  eval &ns=$namespace $script-code |
    only-bytes

  gather-section
}