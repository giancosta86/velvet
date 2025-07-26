use file
use github.com/giancosta86/aurora-elvish/fs
use github.com/giancosta86/aurora-elvish/map
use ./file-runner

fn run-tests { |&fail-fast=$false includes excludes|
  var global-result = [
    &outcome-map=[&]
    &stats=[&]
  ]

  var global-pipe = (file:pipe)

  fs:wildcard $includes &excludes=$excludes |
    each { |source-path|
      var file-result = (file-runner:run $source-path $fail-fast | from-json)

      set global-result = [
        &outcome-map=(map:merge $global-result[outcome-map] $file-result[outcome-map])
        &stats=(map:merge $global-result[stats] $file-result[stats])
      ]
    }

  put $global-result
}
