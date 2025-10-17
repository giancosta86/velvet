use ./section
use ./test-script

var test-script-paths = $args

all $test-script-paths | each { |test-script-path|
  test-script:run $test-script-path
} |
  section:merge |
  to-json