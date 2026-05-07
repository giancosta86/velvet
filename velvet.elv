use os
use github.com/giancosta86/ethereal/v1/parallel
use github.com/giancosta86/ethereal/v1/seq
use ./aggregator
use ./reporting/console/full
use ./reporting/console/terse
use ./summary

#
# Emits all the **.test.elv** test scripts in the current directory tree.
#
fn get-test-scripts {
  put **[nomatch-ok].test.elv
}

fn -resolve-test-scripts {
  var items-from-pipe = $false

  each { |script-path|
    set items-from-pipe = $true

    if (not (os:is-regular $script-path)) {
      var path-with-extension = $script-path'.test.elv'

      if (os:is-regular $path-with-extension) {
        put $path-with-extension
      } elif (os:is-dir $script-path) {
        put $script-path/**[nomatch-ok].test.elv
      } else {
        put $script-path
      }
    } else {
      put $script-path
    }
  }

  if (not $items-from-pipe) {
    get-test-scripts
  }
}

#
# Runs the Velvet test system.
#
fn velvet { |&flawless=$false &emit-summary=$false &verbose=$false &reporters=[$terse:report~] &num-workers=$parallel:DEFAULT-NUM-WORKERS @script-paths|
  var sandbox-result = (
    all $script-paths |
      -resolve-test-scripts |
      aggregator:run-test-scripts &num-workers=$num-workers
  )

  var summary = (summary:from-sandbox-result $sandbox-result)

  if $verbose {
    set reporters = [$full:report~]
  }

  all $reporters | each { |reporter|
    $reporter $summary |
      only-bytes
  }

  var has-failed-tests = (> $summary[stats][failed] 0)

  var has-crashed-scripts = (seq:is-non-empty $summary[crashed-scripts])

  var has-flaws = (or $has-failed-tests $has-crashed-scripts)

  if (and $flawless $has-flaws) {
    fail '❌ There are flaws in the tests!'
  }

  if $emit-summary {
    put $summary
  }
}