use path
use github.com/giancosta86/aurora-elvish/console
use ./namespace

fn main { |source-path fail-fast|
  var source-string = (slurp < $source-path)

  var namespace-controller = (namespace:create &fail-fast=$fail-fast $source-path)

  tmp pwd = (path:dir $source-path)
  eval &ns=$namespace-controller[namespace] $source-string

  console:inspect &emoji=🐿 'CONTEXT RIGHT HERE' ($namespace-controller[get-outcome-context])

  var file-result = [
    &stats=($namespace-controller[get-stats])
    &outcome-context=($namespace-controller[get-outcome-context])
  ]

  console:inspect &emoji=🐬 'FILE RESULT IS' $file-result

  put $file-result | to-json
}

var inputs = (echo $args[0] | from-json)
var source-path = $inputs[source-path]
var fail-fast = $inputs[fail-fast]

main $source-path $fail-fast