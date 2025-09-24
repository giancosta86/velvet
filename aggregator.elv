use ./describe-result
use ./test-script

fn run-test-scripts { |@test-scripts|
  var describe-results = [(all $test-scripts | each { |test-script| #TODO! peach!
    test-script:run $test-script
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