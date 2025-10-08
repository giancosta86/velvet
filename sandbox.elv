use ./test-script

var script-file = $args[0]

test-script:run $script-file | only-values | to-json