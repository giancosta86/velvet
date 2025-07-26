use path
use github.com/giancosta86/aurora-elvish/elvish
use github.com/giancosta86/aurora-elvish/fs
use github.com/giancosta86/aurora-elvish/map
use github.com/giancosta86/aurora-elvish/resources

var -resources = (resources:for-script (src))

var -file-runner-script = ($-resources[get-path] file-runner.main.elv)

var -file-runner-code = (slurp < $-file-runner-script)

fn run-tests { |&fail-fast=$false includes excludes|
  var global-result = [
    &outcome-map=[&]
    &stats=[&]
  ]

  fs:wildcard $includes &excludes=$excludes |
    each { |source-path|
      var file-runner-inputs = [
        &source-path=(path:abs $source-path)
        &fail-fast=$fail-fast #TODO! Handle fail-fast here, too?
      ]

      var file-result = (elvish:run-transform $-file-runner-code $file-runner-inputs | only-values)

      set global-result = [
        &outcome-map=(map:merge $global-result[outcome-map] $file-result[outcome-map])
        &stats=(map:merge $global-result[stats] $file-result[stats])
      ]
    }

  put $global-result
}
