use path
use ./namespace

fn main { |source-path fail-fast|
  var source-string = (slurp < $source-path)

  var namespace-controller = (namespace:create &fail-fast=$fail-fast $source-path)

  tmp pwd = (path:dir $source-path)
  eval &ns=$namespace-controller[namespace] $source-string

  var file-result = [
    &stats=($namespace-controller[get-stats])
    &result-context=($namespace-controller[to-result-context])
  ]

  put $file-result | to-json
}

var inputs = (echo $args[0] | from-json)
var source-path = $inputs[source-path]
var fail-fast = $inputs[fail-fast]

main $source-path $fail-fast