use ./test-script

var script-file = $args[0]

test-script:run $script-file | to-json