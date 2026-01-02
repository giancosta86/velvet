use ../tests/aggregator/summaries
use ./spy

>> 'Reporter spy' {
  >> 'retrieving the summary' {
    >> 'upon creation' {
      var spy = (spy:create)

      $spy[get-summary] |
        should-be $nil
    }

    >> 'upon after calling the reporter function' {
      var spy = (spy:create)

      var test-summary = $summaries:alpha-beta

      $spy[reporter] $test-summary

      $spy[get-summary] |
        should-be $test-summary
    }
  }
}