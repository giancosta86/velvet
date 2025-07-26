use github.com/giancosta86/aurora-elvish/fs
use github.com/giancosta86/aurora-elvish/resources
use github.com/giancosta86/aurora-elvish/seq
use ./core
use ./reporting/cli

var -resources = (resources:for-script (src))

var -sandbox-script = ($-resources[get-path] sandbox.main.elv)

var -default-includes = '**[type:regular][nomatch-ok].test.elv'

fn has-test-files { |&includes=$-default-includes &excludes=$nil|
  fs:wildcard $includes &excludes=$excludes |
    take 1 |
    count |
    != (all) 0
}

fn test { |
  &includes=$-default-includes
  &excludes=$nil
  &fail-fast=$false
  &reporters=[$cli:display~]
|
  var sandbox-inputs = [
    &includes=$includes
    &excludes=$excludes
    &fail-fast=$fail-fast
  ]

  var sandbox-inputs-json = (put $sandbox-inputs | to-json)

  var sandbox-output = (
    elvish $-sandbox-script $sandbox-inputs-json
  )

  var sandbox-result = (echo $sandbox-output | from-json)

  if (seq:is-non-empty $reporters) {
    var outcome-map = $sandbox-result[outcome-map]

    all $reporters | each { |reporter|
      $reporter $outcome-map
    }
  }

  var stats = $sandbox-result[stats]


  if $stats[is-ok] {
    var message = 'All the '$stats[total-tests]' tests passed.'
    $core:tracer[echo] (styled $message green bold)
  } else {
    var message = 'Failed tests: '$stats[total-failed]' out of '$stats[total-tests]'.'
    $core:tracer[echo] (styled $message red bold)
  }

  put $sandbox-result
}