use github.com/giancosta86/aurora-elvish/map
use github.com/giancosta86/aurora-elvish/seq

fn ensure-context { |map title factory|
  var existing-context = (map:get-value $map $title)

  if $existing-context {
    put [
      &context=$existing-context
      &updated-map=$map
    ]
  } else {
    var new-context = ($factory)

    var updated-map = (assoc $map $title $new-context)

    put [
      &context=$new-context
      &updated-map=$updated-map
    ]
  }
}

fn to-outcome-context { |context-map|
  map:entries $context-map |
    seq:each-spread { |describe-title context|
      var outcome-context = ($context[to-outcome-context])

      put [$describe-title $outcome-context]
    } |
    make-map
}
