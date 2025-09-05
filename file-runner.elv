use path
use github.com/giancosta86/aurora-elvish/resources

var -main-code = ({
  var resources = (resources:for-script (src))
  var main-script = ($resources[get-path] file-runner.main.elv)

  slurp < $main-script
})

fn run { |&fail-fast=$false source-path|
  var inputs = [
    &source-path=(path:abs $source-path)
    &fail-fast=$fail-fast #TODO! Handle fail-fast as a failure, in this runner or in the global one?
  ]

  var inputs-json = (put $inputs | to-json)

  var outputs-json = (elvish -c $-main-code $inputs-json)

  echo $outputs-json | from-json
}