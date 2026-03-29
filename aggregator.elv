use path
use github.com/giancosta86/ethereal/v1/parallel
use ./sandbox-result

var run-test-scripts~ = (
  var sandbox-script-path = (
    put (src)[name] |
      path:dir (all) |
      path:join (all) sandbox.elv
  )

  fn run-chunk-in-elvish-sandbox { |@chunk-script-paths|
    elvish -norc $sandbox-script-path $@chunk-script-paths |
      from-json
  }

  put { |&num-workers=$parallel:DEFAULT-NUM-WORKERS|
    all |
      parallel:fork-join &num-workers=$num-workers $run-chunk-in-elvish-sandbox~ $sandbox-result:merge~
  }
)