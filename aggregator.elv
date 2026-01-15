use path
use github.com/giancosta86/ethereal/v1/parallel
use ./sandbox-result

var DEFAULT-NUM-WORKERS = 8

var -sandbox-script-path = (
  put (src)[name] |
    path:dir (all) |
    path:join (all) sandbox.elv
)

fn -run-chunk-in-elvish-sandbox { |@chunk-script-paths|
  elvish -norc $-sandbox-script-path $@chunk-script-paths |
    from-json
}

fn run-test-scripts { |&num-workers=$DEFAULT-NUM-WORKERS @script-paths|
  all $script-paths |
    parallel:fork-join &num-workers=$num-workers $-run-chunk-in-elvish-sandbox~ $sandbox-result:merge~
}