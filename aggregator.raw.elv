use ./aggregator
use ./assertions
use ./section
use ./tests/aggregator/sections
use ./tests/script-gallery
use ./utils/raw

raw:suite 'Aggregator' { |test~|
  fn get-test-script { |basename|
    script-gallery:get-script-path aggregator $basename
  }

  test 'Running no scripts' {
    aggregator:run-test-scripts |
      assertions:should-be $section:empty
  }

  test 'Running 1 script' {
    aggregator:run-test-scripts (get-test-script alpha) |
      assertions:should-be $sections:alpha
  }

  test 'Running 2 scripts' {
    aggregator:run-test-scripts (get-test-script alpha) (get-test-script beta) |
      assertions:should-be $sections:alpha-beta
  }

  test 'Running 3 scripts' {
    aggregator:run-test-scripts (get-test-script alpha) (get-test-script beta) (get-test-script gamma) |
      section:simplify (all) |
      assertions:should-be $sections:alpha-beta-gamma
  }

  test 'Running the same 3 scripts with different numbers of workers' {
    var script-paths = [(get-test-script alpha) (get-test-script beta) (get-test-script gamma)]

    range 1 4 | each { |num-workers|
      aggregator:run-test-scripts &num-workers=$num-workers $@script-paths |
        section:simplify (all) |
        assertions:should-be $sections:alpha-beta-gamma
    }
  }
}