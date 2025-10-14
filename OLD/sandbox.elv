use ./describe-result
use ./test-script

var test-script-paths = $args

all $test-script-paths | each { |test-script-path|
  test-script:run $test-script-path | only-values
} |
  describe-result:merge |
  to-json