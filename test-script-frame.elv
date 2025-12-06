use str
use github.com/giancosta86/ethereal/v1/command
use github.com/giancosta86/ethereal/v1/exception
use ./exception-lines
use ./outcomes
use ./section
use ./test-result

fn create { |script-path title|
  var block-result = $nil
  var sub-frames = []

  fn run-block { |block|
    if $block-result {
      fail 'Block result already set in frame: '$title
    }

    set block-result = (command:capture &type=bytes $block)
  }

  fn add-sub-frame { |sub-frame|
    set sub-frames = [$@sub-frames $sub-frame]
  }

  fn to-test-result {
    var exception = $block-result[exception]

    var test-passed = (
      or (eq $exception $nil) (exception:is-return $exception)
    )

    var exception-log = (
      if (not $test-passed) {
        show $exception |
          exception-lines:trim-clockwork-stack |
          exception-lines:replace-bottom-eval $script-path |
          str:join "\n"
      } else {
        put $nil
      }
    )

    var outcome = (
      if $test-passed {
        put $outcomes:passed
      } else {
        put $outcomes:failed
      }
    )

    var output = (
      all $block-result[data] |
        to-lines |
        slurp
    )

    put [
      &output=$output
      &exception-log=$exception-log
      &outcome=$outcome
    ]
  }

  fn to-section {
    var test-results = [&]
    var sub-sections = [&]

    all $sub-frames | each { |sub-frame|
      var sub-title = $sub-frame[title]

      var sub-artifact = ($sub-frame[to-artifact])

      if (section:is-section $sub-artifact) {
        var up-to-date-section = (
          if (has-key $sub-sections $sub-title) {
            var existing-section = $sub-sections[$sub-title]

            put $existing-section $sub-artifact |
              section:merge
          } else {
            put $sub-artifact
          }
        )

        set sub-sections = (assoc $sub-sections $sub-title $up-to-date-section)
      } else {
        var updated-test-result = (
          if (has-key $test-results $sub-title) {
            put $test-result:duplicate
          } else {
            put $sub-artifact
          }
        )

        set test-results = (assoc $test-results $sub-title $updated-test-result)
      }
    }

    put [
      &test-results=$test-results
      &sub-sections=$sub-sections
    ]
  }

  fn to-artifact {
    if (not $block-result) {
      fail 'Cannot obtain artifact when block result is not set, in frame: '$title
    }

    var is-section-frame = (> (count $sub-frames) 0)

    if $is-section-frame {
      var exception = $block-result[exception]

      if (not-eq $exception $nil) {
        fail $exception
      }

      to-section
    } else {
      to-test-result
    }
  }

  put [
    &title=$title
    &add-sub-frame=$add-sub-frame~
    &run-block=$run-block~
    &to-artifact=$to-artifact~
  ]
}