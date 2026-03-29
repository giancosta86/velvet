use ../section
use ../test-result
use ./frame
use ./root-frames

var passing-block = {
  echo Hello
}

var failing-block = {
  echo World
  fail Dodo
}

>> 'Test script root frames' {
  >> 'should be convertible to section' {
    var script-path = 'example.test.elv'

    var root-frames = (root-frames:create)

    var alpha = (frame:create $script-path Alpha)
    $root-frames[append] $alpha
    $alpha[run-block] $passing-block

    var beta = (frame:create $script-path Beta)
    $root-frames[append] $beta

    $beta[run-block] {
      var gamma = (frame:create $script-path Gamma)
      $beta[add-sub-frame] $gamma

      $gamma[run-block] {
        var delta = (frame:create $script-path Delta)
        $gamma[add-sub-frame] $delta

        $delta[run-block] $failing-block
      }
    }

    $root-frames[to-section] |
      section:simplify |
      should-be (
        section:create [&Alpha=(test-result:success [Hello])] [
          &Beta=(section:create [&] [
            &Gamma=(section:create [&Delta=(test-result:failure [World] [])])
          ])
        ]
      )
  }
}