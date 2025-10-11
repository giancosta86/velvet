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

    &add-test-result={ |test-title test-result|
      var actual-test-result = (
        if (has-key $test-results $test-title) {
          test-result:create-for-duplicated
        } else {
          put $test-result
        }
      )

      set test-results = (assoc $test-results $test-title $actual-test-result)
    }

    &to-result={
      var sub-results = (
        map:filter-map $sub-contexts { |sub-title sub-context|
          var sub-result = ($sub-context[to-result])

          var sub-count = (+ (count $sub-result[test-results]) (count $sub-result[sub-results]))

          if (> $sub-count 0) {
            put [$sub-title $sub-result]
          } else {
            put $nil
          }
        }
      )

      put [
        &test-results=$test-results
        &sub-results=$sub-results
      ]
    }
  ]
}