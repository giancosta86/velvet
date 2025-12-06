use ./aggregator
use ./section
use ./tests/aggregator/summaries
use ./tests/script-gallery

fn get-test-script { |basename|
  script-gallery:get-script-path aggregator $basename
}

>> 'Aggregator' {
  >> 'running no scripts' {
    aggregator:run-test-scripts |
      should-be $section:empty
  }

  >> 'running 1 script' {
    aggregator:run-test-scripts (get-test-script alpha) |
      should-be $summaries:alpha[section]
  }

  >> 'running 2 scripts' {
    aggregator:run-test-scripts (get-test-script alpha) (get-test-script beta) |
      should-be $summaries:alpha-beta[section]
  }

  >> 'running the same 3 scripts with different numbers of workers' {
    var script-paths = [(get-test-script alpha) (get-test-script beta) (get-test-script gamma)]

    range 1 5 | each { |num-workers|
      aggregator:run-test-scripts &num-workers=$num-workers $@script-paths |
        section:simplify (all) |
        should-be $summaries:alpha-beta-gamma-simplified[section]
    }
  }
}