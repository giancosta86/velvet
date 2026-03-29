use path
use github.com/giancosta86/ethereal/v1/map
use ./assertions
use ./ethereal
use ./test-script/frame
use ./test-script/root-frames
use ./tools

fn run { |script-path|
  var abs-script-path = (path:abs $script-path)
  var script-code = (slurp < $script-path)

  var root-frames = ($root-frames:create)
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
      var rest-length = (count $rest)

      if (== $rest-length 1) {
        put $rest[0]
      } elif (== $rest-length 0) {
        put $assertions:fail-test~
      } else {
        fail 'Only 1 or 2 arguments are allowed!'
      }
    )

    var this-frame = (
      frame:create $abs-script-path $title
    )

    var parent-frame = $current-frame

    if $parent-frame {
      $parent-frame[add-sub-frame] $this-frame
    } else {
      root-frames[append] $this-frame
    }

    tmp current-frame = $this-frame

    $current-frame[run-block] $block
  }

  var core-functions = [
    &src~=$custom-src~
    &'>>'~=$'>>~'
  ]

  var namespace = (
    all [
      $core-functions
      $ethereal:namespaces
      $assertions:
      $tools:
    ] |
      map:merge |
      ns (all)
  )

  tmp pwd = (path:dir $abs-script-path)
  eval &ns=$namespace $script-code |
    only-bytes

  $root-frames[to-section]
}