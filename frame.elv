fn create { |title|
  var block-result = $nil
  var sub-frames = []

  fn set-block-result { |value|
    if $block-result {
      fail 'Block result already set'
    }

    set block-result = $value
  }

  fn add-sub-frame { |sub-frame|
    set sub-frames = [$@sub-frames $sub-frame]
  }

  fn get-sub-frames {
    put $sub-frames
  }

  fn to-result {
    if (not $block-result) {
      fail 'Cannot convert to section with block result not set'
    }

    var test-results = [&]
    var sub-sections = [&]

    var no-sub-frames = (
      count $sub-frames |
        eq (all) 0
    )

    var is-section = $no-sub-frames

    if $is-section {
      put test-result:from-block-result $block-result
      return
    }

    var failing-block-result = (not-eq $block-result[status] $ok) {
      fail $block-result[status]
    }

    all $sub-frames | each { |sub-frame|
      var sub-result = ($sub-frame[to-result])

      var sub-title = $sub-frame[title]

      var is-sub-result-section = (has-key $sub-result $sub-sections)

      if (section:is-section $sub-result) {
        var updated-section = (
          if (has-key $sub-sections $sub-title) {
            var existing-section = $sub-sections[$sub-title]

            section:merge $existing-section $sub-result
          } else {
            put $sub-result
          }
        )

        set sub-sections = (assoc $sub-sections $sub-title $updated-section)
      } else {
        var updated-test-result = (
          if (has-key $tests $sub-title) {
            put test-result:create-for-duplicated
          } else {
            put test-result:from-block-result $block-result
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

  put [
    &title=$title
    &set-block-result=$set-block-result~
    &add-sub-frame=$add-sub-frame~
    &get-sub-frames=$get-sub-frames~
    &to-section=$to-section~
  ]
}