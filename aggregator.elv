use path
use ./describe-result

var -sandbox-script = (
  put (src)[name] |
    path:dir (all) |
    path:join (all) sandbox.elv
)

fn run-test-scripts { |@test-scripts|
  var describe-results = [(all $test-scripts | peach { |test-script|
    elvish -norc $-sandbox-script $test-script | from-json
  })]

  var result = [
    &test-results=[&]
    &sub-results=[&]
  ]

  all $describe-results | each { |describe-result|
    set result = (describe-result:merge $result $describe-result)
  }

  put $result
}