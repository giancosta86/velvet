use github.com/giancosta86/ethereal/v1/seq
use ./aggregator
use ./reporting/console/terse
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

fn velvet { |&must-pass=$false &put=$false &reporters=[$terse:report~] &num-workers=$aggregator:DEFAULT-NUM-WORKERS @script-paths|
  var actual-test-scripts = (
    if (> (count $script-paths) 0) {
      put $script-paths
    } else {
      put [(get-test-scripts)]
    }
  )

  var sandbox-result = (aggregator:run-test-scripts &num-workers=$num-workers $@actual-test-scripts)

  var summary = (summary:from-sandbox-result $sandbox-result)

  all $reporters | each { |reporter|
    $reporter $summary |
      only-bytes
  }

  var has-failed-tests = (> $summary[stats][failed] 0)

  var has-crashed-scripts = (seq:is-non-empty $summary[crashed-scripts])

  var has-flaws = (or $has-failed-tests $has-crashed-scripts)

  if (and $must-pass $has-flaws) {
    fail '❌ There are failed tests!'
  }

  if $put {
    put $summary
  }
}