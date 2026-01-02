use ../tests/aggregator/summaries
use ./json

>> 'JSON reporter' {
  >> 'when reporting to a file path' {
    fs:with-temp-file { |json-file|
      var reporter~ = (json:report $json-file)

      var test-summary = $summaries:alpha-beta

      reporter $test-summary

      from-json < $json-file |
        should-be $test-summary
    }
  }
}