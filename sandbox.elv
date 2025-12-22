use github.com/giancosta86/ethereal/v1/seq
use ./exception-lines
use ./sandbox-result
use ./section
use ./test-script

var test-script-paths = $args

all $test-script-paths |
  seq:reduce $sandbox-result:empty { |cumulated-sandbox-result script-path|
    var script-sandbox-result = (
      try {
        var section = (test-script:run $script-path)

        put [
          &section=$section
          &crashed-scripts=[&]
        ]
      } catch e {
        var exception-lines = [(
          show $e |
            exception-lines:trim-clockwork-stack |
            exception-lines:replace-bottom-eval $script-path
        )]

        put [
          &section=$section:empty
          &crashed-scripts=[
            &$script-path=$exception-lines
          ]
        ]
      }
    )

    sandbox-result:merge $cumulated-sandbox-result $script-sandbox-result
  } |
  to-json