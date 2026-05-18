use path
use ./test-script/frame
use ./test-script/namespace
use ./test-script/root-frames
use ./tools

fn run { |script-path|
  var abs-script-path = (path:abs $script-path)
  var script-code = (slurp < $script-path)

  var root-frames = (root-frames:create)
  var current-frame = $nil

  fn custom-src {
    put [
      &is-file=$true
      &name=$abs-script-path
      &code=$script-code
    ]
  }

  fn '>>' { |title @rest|
    if (not-eq (kind-of $title) string) {
      fail 'The title must be a string!'
    }

    var block = (
      var rest-count = (count $rest)

      if (== $rest-count 1) {
        put $rest[0]
      } elif (== $rest-count 0) {
        put $tools:fail-test~
      } else {
        fail 'Only <title> or <title> <block> arguments are allowed!'
      }
    )

    var this-frame = (
      frame:create $abs-script-path $title
    )

    var parent-frame = $current-frame

    if $parent-frame {
      $parent-frame[add-sub-frame] $this-frame
    } else {
      $root-frames[append] $this-frame
    }

    tmp current-frame = $this-frame

    $current-frame[run-block] $block
  }

  var script-builtins = [
    &src~=$custom-src~
    &'>>'~=$'>>~'
  ]

  var namespace = (namespace:create-for-script $script-builtins)

  tmp pwd = (path:dir $abs-script-path)

  eval &ns=$namespace $script-code |
    only-bytes

  $root-frames[to-section]
}