use path
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

  fn get-section {
    all $root-frames | each { |root-frame|
      var root-artifact = (root-frame[to-artifact])

      if (section:is $root-artifact) {
        put $root-artifact
      } else {
        var frame-title = $root-frame[title]

        put [
          &test-results=[
            &$frame-title=$frame-result
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
    &expect-throws~=$exception:expect-throws~
    &fail-test~=$assertions:fail-test~
    &should-be~=$assertions:should-be~
    &should-not-be~=$assertions:should-not-be~
  ])

  tmp pwd = (path:dir $abs-script-path)
  eval &ns=$namespace $script-code | only-bytes

  get-section
}