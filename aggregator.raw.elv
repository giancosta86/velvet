use ./aggregator
use ./assertions
use ./describe-result
use ./tests/aggregator/results
use ./tests/test-scripts
use ./utils/raw

raw:suite 'Aggregator' { |test~|
  fn get-test-script { |basename|
    test-scripts:get-path aggregator $basename
  }

  test 'Running no scripts' {
    aggregator:run-test-scripts |
      assertions:should-be [
        &test-results=[&]
        &sub-results=[&]
      ]
  }

  test 'Running 1 script' {
    aggregator:run-test-scripts (get-test-script alpha) |
      assertions:should-be $results:alpha
  }

  test 'Running 2 scripts' {
    aggregator:run-test-scripts (get-test-script alpha) (get-test-script beta) |
      assertions:should-be $results:alpha-beta
  }

  test 'Running 3 scripts' {
    aggregator:run-test-scripts (get-test-script alpha) (get-test-script beta) (get-test-script gamma) |
      describe-result:simplify (all) |
      assertions:should-be $results:alpha-beta-gamma
  }

  test 'Running the same 3 scripts with different numbers of workers' {
    var script-paths = [(get-test-script alpha) (get-test-script beta) (get-test-script gamma)]

    range 1 4 | each { |num-workers|
      aggregator:run-test-scripts &num-workers=$num-workers $@script-paths |
        describe-result:simplify (all) |
        assertions:should-be $results:alpha-beta-gamma
    }
  }
}