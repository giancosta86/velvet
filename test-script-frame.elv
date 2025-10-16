use str
use ./outcomes
use ./section
use ./utils/exception-lines

fn create { |script-path title|
  var block-result = $nil
  var sub-frames = []

  fn run-block { |block|
    if $block-result {
      fail 'Block result already set in frame: '$title
    }

    set block-result = (command:capture $block)
  }

  fn add-sub-frame { |sub-frame|
    set sub-frames = [$@sub-frames $sub-frame]
  }

  fn create-test-result { |exception-log|
    var outcome = (
      if $exception-log {
        put $outcomes:failed
      } else {
        put $outcomes:passed
      }
    )

    put [
      &output=$block-result[output]
      &exception-log=$exception-log
      &outcome=$outcome
    ]
  }

  fn create-section {
    var test-results = [&]
    var sub-sections = [&]

    var failing-block-result = (not-eq $block-result[status] $ok) {
      fail $block-result[status]
    }

    all $sub-frames | each { |sub-frame|
      var sub-title = $sub-frame[title]

      var sub-artifact = ($sub-frame[to-artifact])

      if (section:is $sub-artifact) {
        var up-to-date-section = (
          if (has-key $sub-sections $sub-title) {
            var existing-section = $sub-sections[$sub-title]
            section:merge $existing-section $sub-artifact
          } else {
            put $sub-artifact
          }
        )

        set sub-sections = (assoc $sub-sections $sub-title $up-to-date-section)
      } else {
        var updated-test-result = (
          if (has-key $test-results $sub-title) {
            test-result:create-for-duplicated
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

    var exception-log = (
      if $block-result[exception] {
        show $block-result[exception] |
          exception-lines:trim-clockwork-stack |
          exception-lines:replace-bottom-eval $script-path |
          str:join "\n"
      } else {
        put $nil
      }
    )

    var has-sub-frames = (> (count $sub-frames) 0)

    if $has-sub-frames {
      if $exception-log {
        echo $exception-log >&2
        exit 1
      }

      create-section
    } else {
      create-test-result $exception-log
    }
  }

  put [
    &title=$title
    &run-block=$run-block~
    &add-sub-frame=$add-sub-frame~
    &to-artifact=$to-artifact~
  ]
}