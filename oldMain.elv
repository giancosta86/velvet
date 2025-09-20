use github.com/giancosta86/aurora-elvish/console
use github.com/giancosta86/aurora-elvish/fs
use github.com/giancosta86/aurora-elvish/seq
use ./global-runner
use ./reporting/cli

var -default-includes = '**[type:regular][nomatch-ok].test.elv'

fn has-test-files { |&includes=$-default-includes &excludes=$nil|
  fs:wildcard $includes &excludes=$excludes |
    take 1 |
    count |
    != (all) 0
}

fn run-tests { |
  &includes=$-default-includes
  &excludes=$nil
  &fail-fast=$false
  &reporters=[$cli:display~]
|
  var global-result = (global-runner:run-tests &fail-fast=$fail-fast $includes $excludes)

  if (seq:is-non-empty $reporters) {
    var result-context = $global-result[result-context]

    all $reporters | each { |reporter|
      $reporter $result-context
    }
  }

  var stats = $global-result[stats]

  if $stats[is-ok] {
    var message = 'All the '$stats[total-tests]' tests passed.'
    console:echo (styled $message green bold)
  } else {
    var message = 'Failed tests: '$stats[total-failed]' out of '$stats[total-tests]'.'
    console:echo (styled $message red bold)
  }

  put $global-result
}


fn test { |
  &includes=$-default-includes
  &excludes=$nil
  &fail-fast=$false
  &reporters=[$cli:display~]
|

  run-tests &includes=$includes &excludes=$excludes &fail-fast=$fail-fast &reporters=$reporters | only-bytes
}