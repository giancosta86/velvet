use os
use path
use github.com/giancosta86/ethereal/v1/fs
use github.com/giancosta86/ethereal/v1/parallel
use github.com/giancosta86/ethereal/v1/seq
use ./aggregator
use ./reporting/console/full
use ./reporting/console/terse
use ./summary

var -default-reporters = [$terse:report~]

fn -resolve-script-path { |script-path|
  if (os:is-regular $script-path) {
    put $script-path
  } else {
    var path-with-extension = $script-path'.test.elv'

    if (os:is-regular $path-with-extension) {
      put $path-with-extension
    } elif (os:is-dir $script-path) {
      tmp pwd = $script-path

      fs:find-test-scripts | each { |current-script|
        path:join $script-path $current-script
      }
    } else {
      put $script-path
    }
  }
}

fn -resolve-test-scripts {
  var paths-from-pipe = [(
    each $-resolve-script-path~
  )]

  if (seq:is-non-empty $paths-from-pipe) {
    all $paths-from-pipe
  } else {
    fs:find-test-scripts
  }
}

#
# Runs the Velvet test system.
#
fn velvet { |&flawless=$false &emit-summary=$false &verbose=$false &reporters=$nil &num-workers=$parallel:DEFAULT-NUM-WORKERS @script-paths|
  var actual-reporters = (
    if $verbose {
      if $reporters {
        fail 'The &verbose flag and the &reporters option are mutually exclusive!'
      }

      put [$full:report~]
    } elif $reporters {
      put $reporters
    } else {
      put $-default-reporters
    }
  )

  var sandbox-result = (
    all $script-paths |
      -resolve-test-scripts |
      aggregator:run-test-scripts &num-workers=$num-workers
  )

  var summary = (summary:from-sandbox-result $sandbox-result)

  all $actual-reporters | each { |reporter|
    $reporter $summary |
      only-bytes
  }

  var has-failed-tests = (> $summary[stats][failed] 0)

  var has-crashed-scripts = (seq:is-non-empty $summary[exception-lines-by-script])

  var has-flaws = (or $has-failed-tests $has-crashed-scripts)

  if (and $flawless $has-flaws) {
    fail '❌ There are flaws in the tests!'
  }

  if $emit-summary {
    put $summary
  }
}