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

# TODO! Add a final test, to test the entire output for a group of scripts
# TODO! The test scripts MUST be the argument of the command!
fn velvet { |&test-scripts=$nil &reporters=[$cli:display~] &num-workers=$aggregator:DEFAULT-NUM-WORKERS|
  var actual-test-scripts = (coalesce $test-scripts [(get-test-scripts)])

  var section = (aggregator:run-test-scripts &num-workers=$num-workers $@actual-test-scripts)
  var stats = (stats:from-section $section)

  all $reporters | each { |reporter|
    $reporter $section $stats | only-bytes
  }

  put [
    &section=$section
    &stats=$stats
  ]

  #TODO! Should I also run "exit 1" on failure in some cases? That would simplify pipelines
}