fn is-function { |value|
  kind-of $value |
    eq "fn" (all)
}

var -minimal-transforms-by-kind

fn minimize { |value|
  var kind = (kind-of $value)

  if (has-key $-minimal-transforms-by-kind $kind) {
    $-minimal-transforms-by-kind[$kind] $value
  } else {
    to-string $value
  }
}

set -minimal-transforms-by-kind = [
  &list={ |list|
    all $list |
      each $minimize~ |
      put [(all)]
  }
  &map={ |map|
    keys $map | each { |key|
      var value = $map[$key]
      put [(minimize $key) (minimize $value)]
    } |
      make-map
  }
]