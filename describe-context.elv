use github.com/giancosta86/aurora-elvish/exception
use github.com/giancosta86/aurora-elvish/lang
use github.com/giancosta86/aurora-elvish/map
use github.com/giancosta86/aurora-elvish/seq
use ./outcomes
use ./test-result

fn create {
  var test-results = [&]
  var sub-contexts = [&]

  put [
    &ensure-sub-context={ |sub-title|
      var existing-context = (map:get-value $sub-contexts $sub-title)

      if $existing-context {
        put $existing-context
      } else {
        var new-context = (create)

        set sub-contexts = (assoc $sub-contexts $sub-title $new-context)

        put $new-context
      }
    }

    &run-test={ |test-title block|
      var test-result = (
        if (has-key $test-results $test-title) {
          test-result:create-for-duplicated-test
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