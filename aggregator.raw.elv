use ./aggregator
use ./assertions
use ./section
use ./tests/aggregator/summaries
use ./tests/script-gallery
use ./utils/raw

fn get-test-script { |basename|
  script-gallery:get-script-path aggregator $basename
}

raw:suite 'Aggregator' { |test~|
  test 'Running no scripts' {
    aggregator:run-test-scripts |
      assertions:should-be $section:empty
  }

  test 'Running 1 script' {
    aggregator:run-test-scripts (get-test-script alpha) |
      assertions:should-be $summaries:alpha[section]
  }

  test 'Running 2 scripts' {
    aggregator:run-test-scripts (get-test-script alpha) (get-test-script beta) |
      assertions:should-be $summaries:alpha-beta[section]
  }

  test 'Running the same 3 scripts with different numbers of workers' {
    var script-paths = [(get-test-script alpha) (get-test-script beta) (get-test-script gamma)]

    range 1 5 | each { |num-workers|
      aggregator:run-test-scripts &num-workers=$num-workers $@script-paths |
        section:simplify (all) |
        assertions:should-be $summaries:alpha-beta-gamma-simplified[section]
    }
  }
}