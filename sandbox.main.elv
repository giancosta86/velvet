use ./core
use ./sandbox/global-runner

var inputs = (echo $args[0] | from-json)

$core:tracer[inspect-inputs] $inputs

var run-result = (global-runner:run-tests $inputs | only-values)

put $run-result | to-json
