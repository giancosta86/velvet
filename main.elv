use ./aggregator
use ./reporting/cli
use ./summary

fn get-test-scripts {
  put **[nomatch-ok].test.elv
}

fn has-test-scripts {
  get-test-scripts |
    take 1 |
    count |
    != (all) 0
}

fn velvet { |&must-pass=$false &put=$false &reporters=[$cli:display~] &num-workers=$aggregator:DEFAULT-NUM-WORKERS @script-paths|
  var actual-test-scripts = (
    if (> (count $script-paths) 0) {
      put $script-paths
    } else {
      put [(get-test-scripts)]
    }
  )

  var section = (aggregator:run-test-scripts &num-workers=$num-workers $@actual-test-scripts)

  var summary = (summary:from-section $section)

  all $reporters | each { |reporter|
    $reporter $summary |
      only-bytes
  }

  if (and $must-pass (> $summary[stats][failed] 0)) {
    fail '❌ There are failed tests!'
  }

  if $put {
    put $summary
  }
}