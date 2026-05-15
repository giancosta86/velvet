use str
use ./aggregator
use ./sandbox-result
use ./section
use ./tests/aggregator/summaries
use ./tests/script-gallery

fn get-aggregator-script { |basename|
  script-gallery:get-script-path aggregator $basename
}

>> 'Aggregator' {
  >> 'when running no scripts' {
    all [] |
      aggregator:run-test-scripts |
      should-be $sandbox-result:empty
  }

  >> 'when running 1 script' {
    get-aggregator-script alpha |
      aggregator:run-test-scripts |
      should-be (
        sandbox-result:create $summaries:alpha[section]
      )
  }

  >> 'when running 2 scripts' {
    all [
      (get-aggregator-script alpha)
      (get-aggregator-script beta)
    ] |
      aggregator:run-test-scripts |
      should-be (
        sandbox-result:create $summaries:alpha-beta[section]
      )
  }

  >> 'when running the same 3 scripts with different numbers of workers' {
    range 1 5 | each { |num-workers|
      var sandbox-result = (
        all [
          (get-aggregator-script alpha)
          (get-aggregator-script beta)
          (get-aggregator-script gamma)
        ] |
          aggregator:run-test-scripts &num-workers=$num-workers
      )

      put $sandbox-result[section] |
        section:simplify |
        should-be $summaries:alpha-beta-gamma-simplified[section]

      put $sandbox-result[exception-lines-by-script] |
        should-be [&]
    }
  }

  >> 'when running a crashing script' {
    var crashing-script-path = (script-gallery:get-script-path single-scripts root-test-without-title)

    var sandbox-result = (
      put $crashing-script-path |
        aggregator:run-test-scripts
      )

    put $sandbox-result[section] |
      should-be $section:empty

    all $sandbox-result[exception-lines-by-script][$crashing-script-path] |
      str:join "\n" |
      should-not-contain "test-script.elv"
  }
}