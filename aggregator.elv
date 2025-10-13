use path
use ./describe-result

var -sandbox-script = (
  put (src)[name] |
    path:dir (all) |
    path:join (all) sandbox.elv
)

fn run-test-scripts { |@test-scripts|
  all $test-scripts | peach { |test-script|
    elvish -norc $-sandbox-script $test-script | from-json
  } |
    describe-result:merge
}