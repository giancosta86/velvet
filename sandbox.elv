use github.com/giancosta86/ethereal/v1/seq
use ./sandbox-result
use ./section
use ./test-script

var test-script-paths = $args

all $test-script-paths | seq:reduce $sandbox-result:empty { |cumulated-sandbox-result script-path|
  var script-sandbox-result = (
    try {
      test-script:run $script-path |
        sandbox-result:from-section
    } catch e {
      sandbox-result:from-exception $script-path $e
    }
  )

  sandbox-result:merge $cumulated-sandbox-result $script-sandbox-result
} |
  to-json