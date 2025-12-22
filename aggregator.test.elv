use str
use ./aggregator
use ./sandbox-result
use ./section
use ./tests/aggregator/summaries
use ./tests/script-gallery

fn get-test-script { |basename|
  script-gallery:get-script-path aggregator $basename
}

>> 'Aggregator' {
  >> 'when running no scripts' {
    aggregator:run-test-scripts |
      should-be $sandbox-result:empty
  }

  >> 'when running 1 script' {
    aggregator:run-test-scripts (get-test-script alpha) |
      should-be [
        &section=$summaries:alpha[section]
        &crashed-scripts=[&]
      ]
  }

  >> 'when running 2 scripts' {
    aggregator:run-test-scripts (get-test-script alpha) (get-test-script beta) |
      should-be [
        &section=$summaries:alpha-beta[section]
        &crashed-scripts=[&]
      ]
  }

  >> 'when running the same 3 scripts with different numbers of workers' {
    var script-paths = [(get-test-script alpha) (get-test-script beta) (get-test-script gamma)]

    range 1 5 | each { |num-workers|
      var sandbox-result = (aggregator:run-test-scripts &num-workers=$num-workers $@script-paths)

      put $sandbox-result[section] |
        section:simplify (all) |
        should-be $summaries:alpha-beta-gamma-simplified[section]

      put $sandbox-result[crashed-scripts] |
        should-be [&]
    }
  }

  >> 'when running a crashing script' {
    var crashing-script-path = (script-gallery:get-script-path single-scripts root-test-without-title)

    var sandbox-result = (aggregator:run-test-scripts $crashing-script-path)

    put $sandbox-result[section] |
      should-be $section:empty

    var exception-lines = $sandbox-result[crashed-scripts][$crashing-script-path]

    all $exception-lines |
      str:join "\n" |
      str:contains (all) "test-script.elv" |
      should-be $false
  }
}