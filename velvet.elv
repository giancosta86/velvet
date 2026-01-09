use os
use str
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

fn -resolve-test-scripts { |requested-scripts|
  if (== (count $requested-scripts) 0) {
    get-test-scripts
    return
  }

  all $requested-scripts | each { |script-path|
    if (os:is-dir $script-path) {
      put $script-path/**[nomatch-ok].test.elv
    } elif (not (os:is-regular $script-path)) {
      var path-with-extension = $script-path'.test.elv'

      if (os:is-regular $path-with-extension) {
        put $path-with-extension
      } else {
        put $script-path
      }
    } else {
      put $script-path
    }
  }
}

fn velvet { |&must-pass=$false &put=$false &reporters=[$terse:report~] &num-workers=$aggregator:DEFAULT-NUM-WORKERS @script-paths|
  var actual-test-scripts = [(-resolve-test-scripts $script-paths)]

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