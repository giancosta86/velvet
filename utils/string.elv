use ./map

fn get-minimal { |source|
  var source-kind = (kind-of $source)

  if (==s $source-kind list) {
    to-string [(all $source | each $get-minimal~)]
  } elif (==s $source-kind map) {
    to-string (
      map:map $source { |key value|
        put [(get-minimal $key) (get-minimal $value)]
      }
    )
  } else {
    to-string $source
  }
}