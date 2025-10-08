use ./test-script

var test-script-file = $args[0]

test-script:run $test-script-file | only-values | to-json