use ./aggregator
use ./reporting/cli

fn get-test-scripts {
  put [**[nomatch-ok].test.elv]
}

fn has-test-scripts {
  get-test-scripts |
    all (all) |
    take 1 |
    count |
    != (all) 0
}

fn test { |&test-scripts=$nil &reporters=[$cli:display~]|
  var actual-test-scripts = (coalesce $test-scripts (get-test-scripts))

  var describe-result = (aggregator:run-test-scripts $@actual-test-scripts)

  all $reporters | each { |reporter~|
    reporter $describe-result
  }
}