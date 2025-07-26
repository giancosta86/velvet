use ./core
use ./sandbox/bootstrap

var inputs = (echo $args[0] | from-json)

$core:tracer[inspect-inputs] $inputs

var run-result = (bootstrap:run-tests $inputs | only-values)

put $run-result | to-json
