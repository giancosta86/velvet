use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/ethereal/v1/operator
use ./outcomes
use ./test-result

fn create { |@arguments|
  var test-results sub-sections = (
    all $arguments |
      lang:ensure-put &default=[&] &min-values=2
  )

  put [
    &test-results=$test-results
    &sub-sections=$sub-sections
  ]
}

var empty = (create)

fn is-section { |@arguments|
  var artifact = (lang:get-single-input $arguments)

  and (has-key $artifact test-results) (has-key $artifact sub-sections)
}

fn add-test-result { |@arguments|
  var section test-title test-result = (
    lang:get-mixed-inputs &min-values=3 &max-values=3 &min-args=2 $arguments
  )

  assoc $section[test-results] $test-title $test-result |
    assoc $section test-results (all)
}

fn add-sub-section { |@arguments|
  var section sub-title sub-section = (
    lang:get-mixed-inputs &min-values=3 &max-values=3 &min-args=2 $arguments
  )

  assoc $section[sub-sections] $sub-title $sub-section |
    assoc $section sub-sections (all)
}

fn map-test-results-in-tree { |@arguments|
  var root-section test-result-mapper = (
    lang:get-mixed-inputs &min-values=2 &max-values=2 &min-args=1 $arguments
  )

  var updated-test-results = (
    map:transform $root-section[test-results] { |test-title test-result|
      put [$test-title ($test-result-mapper $test-result)]
    }
  )

  var updated-sub-sections = (
    map:transform $root-section[sub-sections] { |sub-title sub-section|
      put [$sub-title (map-test-results-in-tree $sub-section $test-result-mapper)]
    }
  )

  create $updated-test-results $updated-sub-sections
}

fn simplify { |@arguments|
  lang:get-single-input $arguments |
    map-test-results-in-tree $test-result:simplify~
}

fn trim-empty { |@arguments|
  var section = (lang:get-single-input $arguments)

  var updated-sub-sections = (
    map:transform $section[sub-sections] { |sub-section-title sub-section|
      var updated-sub-section = (trim-empty $sub-section)

      if (not-eq $updated-sub-section $empty) {
        put [$sub-section-title $updated-sub-section]
      }
    }
  )

  assoc $section sub-sections $updated-sub-sections
}

fn keep-failed-test-results { |@arguments|
  var section = (lang:get-single-input $arguments)

  var filtered-test-results = (
    map:keep-if $section[test-results] { |_ test-result|
      eq $test-result[outcome] $outcomes:failed
    }
  )

  var updated-sub-sections = (
    map:transform $section[sub-sections] { |sub-section-title sub-section|
      var updated-sub-section = (keep-failed-test-results $sub-section)

      put [$sub-section-title $updated-sub-section]
    }
  )

  put [
    &test-results=$filtered-test-results
    &sub-sections=$updated-sub-sections
  ] |
    trim-empty (all)
}

var merge~ = (
  var merge-test-results~
  var merge-sub-sections~

  fn merge-two-sections { |left right|
    create (
      merge-test-results $left[test-results] $right[test-results]
    ) (
      merge-sub-sections $left[sub-sections] $right[sub-sections]
    )
  }

  set merge-test-results~ = { |left right|
    var test-results = $left

    keys $right | each { |test-title|
      var actual-test-result = (
        if (has-key $left $test-title)  {
          put $test-result:duplicate-test
        } else {
          put $right[$test-title]
        }
      )

      set test-results = (assoc $test-results $test-title $actual-test-result)
    }

    put $test-results
  }

  set merge-sub-sections~ = { |left right|
    var sub-sections = $left

    keys $right | each { |sub-title|
      var actual-sub-section = (
        if (has-key $left $sub-title)  {
          merge-two-sections $left[$sub-title] $right[$sub-title]
        } else {
          put $right[$sub-title]
        }
      )

      set sub-sections = (assoc $sub-sections $sub-title $actual-sub-section)
    }

    put $sub-sections
  }

  operator:multi-value $empty $merge-two-sections~
)
