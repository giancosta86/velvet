use ./outcomes
use ./test-result
use ./utils/map

fn create {
  var test-results = [&]
  var sub-contexts = [&]

  put [
    &ensure-sub-context={ |sub-title|
      if (has-key $sub-contexts $sub-title) {
        put $sub-contexts[$sub-title]
      } else {
        var new-context = (create)

        set sub-contexts = (assoc $sub-contexts $sub-title $new-context)

        put $new-context
      }
    }

    &run-test={ |test-title block|
      var test-result = (
        if (has-key $test-results $test-title) {
          test-result:create-for-duplicated
        } else {
          test-result:from-block $block
        }
      )

      set test-results = (assoc $test-results $test-title $test-result)

      put $test-result
    }

    &to-result={
      var sub-results = (
        map:map $sub-contexts { |sub-title sub-context|
          put [$sub-title ($sub-context[to-result])]
        }
      )

      put [
        &test-results=$test-results
        &sub-results=$sub-results
      ]
    }
  ]
}