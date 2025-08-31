use file
use github.com/giancosta86/aurora-elvish/fs
use github.com/giancosta86/aurora-elvish/map
use ./file-runner

fn run-tests { |&fail-fast=$false includes excludes|
  var global-result = [
    &outcome-context=[&]
    &stats=[&]
  ]

  var global-pipe = (file:pipe)

  fs:wildcard $includes &excludes=$excludes |
    peach { |source-path|
      var file-result = (file-runner:run &fail-fast=$fail-fast $source-path)

      echo $file-result > $global-pipe
    }

  file:close $global-pipe[w]

  slurp < $global-pipe | to-lines | each { |file-result|
    use github.com/giancosta86/aurora-elvish/console
    console:inspect 'FILE RESULT' $file-result

    set global-result = [
      &outcome-context=(map:merge $global-result[outcome-context] $file-result[outcome-context])
      &stats=(map:merge $global-result[stats] $file-result[stats])
    ]
  }

  put $global-result
}
