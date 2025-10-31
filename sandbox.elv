use ./section
use ./test-script

var test-script-paths = $args

all $test-script-paths |
  each $test-script:run~ |
  section:merge |
  to-json