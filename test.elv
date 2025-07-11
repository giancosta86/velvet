use ../console
use ../fs
use ../resources
use ../seq
use ./reporting/cli

var -resources = (resources:for-script (src))

var -default-includes = '**[type:regular][nomatch-ok].test.elv'

fn has-tests { |&includes=$-default-includes &excludes=$nil|
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
  var inputs = [
    &includes=$includes
    &excludes=$excludes
    &fail-fast=$fail-fast
  ]

  var inputs-json = (put $inputs | to-json)

  var runner-script = ($-resources[get-path] runner.main.elv)

  var runner-output = (
    elvish $runner-script $inputs-json
  )

  var run-result = (echo $runner-output | from-json)

  if (seq:is-non-empty $reporters) {
    var outcome-map = $run-result[outcome-map]

    all $reporters | each { |reporter|
      console:echo
      $reporter $outcome-map
    }
  }

  console:echo

  var stats = $run-result[stats]

  if $stats[is-ok] {
    var message = 'All the '$stats[total-tests]' tests passed.'
    console:echo (styled $message green bold)
  } else {
    var message = 'Failed tests: '$stats[total-failed]' out of '$stats[total-tests]'.'
    console:echo (styled $message red bold)
  }

  put $run-result
}