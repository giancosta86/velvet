use str
use ./aggregator
use ./sandbox-result
use ./section
use ./tests/aggregator/summaries
use ./tests/script-gallery

>> 'Aggregator' {
  >> 'when running no scripts' {
    all [] |
      aggregator:run-test-scripts |
      should-be $sandbox-result:empty
  }

  >> 'when running 1 script' {
    script-gallery:get-aggregator-script alpha |
      aggregator:run-test-scripts |
      should-be (
        sandbox-result:from-section $summaries:alpha[section]
      )
  }

  >> 'when running 2 scripts' {
    all [
      (script-gallery:get-aggregator-script alpha)
      (script-gallery:get-aggregator-script beta)
    ] |
      aggregator:run-test-scripts |
      should-be (
        sandbox-result:from-section $summaries:alpha-beta[section]
      )
  }

  >> 'when running the same 3 scripts with different numbers of workers' {
    range 1 5 | each { |num-workers|
      var sandbox-result = (
        all [
          (script-gallery:get-aggregator-script alpha)
          (script-gallery:get-aggregator-script beta)
          (script-gallery:get-aggregator-script gamma)
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
    var crashing-script-path = (script-gallery:get-standalone-script root-test-without-title)

    var sandbox-result = (
      put $crashing-script-path |
        aggregator:run-test-scripts
    )

    >> 'should output a result with an empty section' {
      put $sandbox-result[section] |
        should-be $section:empty
    }

    >> 'exception log' {
      var exception-log = (
        all $sandbox-result[exception-lines-by-script][$crashing-script-path] |
          str:join "\n"
      )

      >> 'should not mention test-script' {
        put $exception-log |
          should-not-contain "test-script"
      }

      >> 'should not mention sandbox' {
        put $exception-log |
          should-not-contain 'sandbox'
      }

      >> 'should not mention aggregator' {
        put $exception-log |
          should-not-contain 'aggregator'
      }
    }
  }
}