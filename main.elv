use ./aggregator
use ./reporting/cli
use ./stats

fn get-test-scripts {
  put **[nomatch-ok].test.elv
}

fn has-test-scripts {
  get-test-scripts |
    take 1 |
    count |
    != (all) 0
}

fn velvet { |&test-scripts=$nil &reporters=[$cli:display~]|
  var actual-test-scripts = (coalesce $test-scripts [(get-test-scripts)])

  var describe-result = (aggregator:run-test-scripts $@actual-test-scripts)
  var stats = (stats:from-describe-result $describe-result)

  all $reporters | each { |reporter|
    $reporter $describe-result $stats | only-bytes
  }

  put [
    &describe-result=$describe-result
    &stats=$stats
  ]
}