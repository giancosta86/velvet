use ./section
use ./test-result

var passed-test = (test-result:success ['This is a passed test!'])

var failed-test = (test-result:failure ['This is a failed test!'] ?(fail DODO))

>> 'Section' {
  >> 'creation' {
    >> 'when passing no values' {
      all [] |
        section:create |
        should-be [
          &test-results=[&]
          &sub-sections=[&]
        ]
    }

    >> 'when passing just the test results' {
      var test-results = [&alpha=$passed-test]

      section:create $test-results |
        should-be [
          &test-results=$test-results
          &sub-sections=[&]
        ]
    }

    >> 'when passing both the test results and the sub-sections' {
      var test-results = [&alpha=$passed-test]
      var sub-test-results = [&beta=$failed-test]

      var sub-sections = [&sigma=(section:create $sub-test-results)]

      section:create $test-results $sub-sections |
        should-be [
          &test-results=$test-results
          &sub-sections=$sub-sections
        ]
    }
  }

  >> 'detection' {
    >> 'applied to test result' {
      put $passed-test |
        section:is-section |
        should-be $false
    }

    >> 'applied to section' {
      section:is-section $section:empty |
        should-be $true
    }
  }

  >> 'adding a test result' {
    put $section:empty |
      section:add-test-result alpha $passed-test |
      should-be (
        section:create [&alpha=$passed-test]
      )
  }

  >> 'adding a sub-section' {
    var sub-section = (section:create [&] [&alpha=$failed-test])

    put $section:empty |
      section:add-sub-section omega $sub-section |
      should-be (
        section:create [&] [&omega=$sub-section]
      )
  }

  >> 'mapping test results within an entire tree' {
    fn append-hello { |test-result|
      conj $test-result[output-lines] Hello |
        assoc $test-result output-lines (all)
    }

    >> 'with empty section' {
      section:map-test-results-in-tree $section:empty $append-hello~ |
        should-be $section:empty
    }

    >> 'with single root test result' {
      section:create [&alpha=$passed-test] |
        section:map-test-results-in-tree $append-hello~ |
        should-be (
          section:create [
            &alpha=(append-hello $passed-test)
          ]
        )
    }

    >> 'with two root tests' {
      section:create [
        &alpha=$passed-test
        &beta=$failed-test
      ] |
        section:map-test-results-in-tree $append-hello~ |
        should-be (
          section:create [
            &alpha=(append-hello $passed-test)
            &beta=(append-hello $failed-test)
          ]
        )
    }

    >> 'with single test in sub-section' {
      section:create [&] [&sigma=(section:create [&alpha=$passed-test])] |
        section:map-test-results-in-tree $append-hello~ |
        should-be (
          section:create [&] [
            &sigma=(section:create [&alpha=(append-hello $passed-test)])
          ]
        )
    }

    >> 'with tests at different levels' {
      section:create [&alpha=$passed-test] [&sigma=(section:create [&beta=$failed-test])] |
        section:map-test-results-in-tree $append-hello~ |
        should-be (
          section:create [&alpha=(append-hello $passed-test)] [&sigma=(section:create [&beta=(append-hello $failed-test)])]
        )
    }
  }

  >> 'simplification' {
    >> 'on empty section' {
      section:simplify $section:empty |
        should-be $section:empty
    }

    >> 'with just one root test' {
      section:create [&alpha=$passed-test] |
        section:simplify |
        should-be (
          section:create [&alpha=(test-result:simplify $passed-test)]
        )
    }

    >> 'with test in sub-section' {
      section:create [&] [&sigma=(section:create [&beta=$failed-test])] |
        section:simplify |
        should-be (
          section:create [&] [&sigma=(section:create [&beta=(test-result:simplify $failed-test)])]
        )
    }
  }

  >> 'trimming empty sections' {
    >> 'on empty section' {
      section:trim-empty $section:empty |
        should-be $section:empty
    }

    >> 'on a section containing just a test' {
      var section = (section:create [&alpha=$passed-test])

      put $section |
        section:trim-empty |
        should-be $section
    }

    >> 'on a section containing a non-empty sub-section' {
      var section = (
        section:create [&alpha=$passed-test] [&sigma=(section:create [&beta=$failed-test])]
      )

      put $section |
        section:trim-empty |
        should-be $section
    }

    >> 'on a section containing a chain of sub-sections having no test results' {
      section:create [&alpha=$passed-test] [
        &ro=(section:create [&] [
          &sigma=(section:create [&] [
            &tau=(section:create)
          ])
        ])
      ] |
        section:trim-empty |
        should-be (
          section:create [&alpha=$passed-test]
        )
    }
  }

  >> 'keeping only failed test results' {
    >> 'when the section is empty' {
      put $section:empty |
        section:keep-failed-test-results |
        should-be $section:empty
    }

    >> 'when the section contains a passed and a failed test' {
      section:create [&alpha=$passed-test &beta=$failed-test] |
        section:keep-failed-test-results |
        should-be (
          section:create [&beta=$failed-test]
        )
    }

    >> 'when the section contains a subsection with a passed and a failed test' {
      section:create [&] [&sigma=(section:create [&alpha=$passed-test &beta=$failed-test])] |
        section:keep-failed-test-results |
        should-be (
          section:create [&] [&sigma=(section:create [&beta=$failed-test])]
        )
    }

    >> 'when the section contains a passed test and a subsection with a failed test' {
      section:create [&alpha=$passed-test] [&sigma=(section:create [&beta=$failed-test])] |
        section:keep-failed-test-results |
        should-be (
          section:create [&] [&sigma=(section:create [&beta=$failed-test])]
        )
    }

    >> 'when the section contains a failed test and a subsection with a passed test' {
      section:create [&alpha=$failed-test] [&sigma=(section:create [&beta=$passed-test])] |
        section:keep-failed-test-results |
        should-be (
          section:create [&alpha=$failed-test]
        )
    }
  }

  >> 'merging' {
    var alpha-test = (test-result:success [Alpha])

    var section-with-alpha = (section:create [&alpha=$alpha-test])

    var beta-test = (test-result:failure [Beta] ?(fail DODO))

    var section-with-beta = (section:create [&beta=$beta-test])

    var gamma-test = (test-result:success [Gamma])

    var section-with-gamma = (section:create [&gamma=$gamma-test])

    >> 'with 0 operands' {
      all [] |
        section:merge |
        should-be $section:empty
    }

    >> 'with 1 operand' {
      all [
        $section-with-alpha
      ] |
        section:merge |
        should-be $section-with-alpha
    }

    >> 'with 2 operands' {
      >> 'when both operands are empty' {
        repeat 2 $section:empty |
          section:merge |
          should-be $section:empty
      }

      >> 'when only the left operand is empty' {
        section:merge $section:empty $section-with-alpha |
          should-be $section-with-alpha
      }

      >> 'when only the right operand is empty' {
        section:merge $section-with-alpha $section:empty |
          should-be $section-with-alpha
      }

      >> 'when both left and right have just a non-duplicate test each' {
        all [
          $section-with-alpha
          $section-with-beta
        ] |
          section:merge |
          should-be (
            section:create [
              &alpha=$alpha-test
              &beta=$beta-test
            ]
          )
      }

      >> 'when two passing tests at the same level have the same name' {
        all [
          (section:create [&omicron=$passed-test])
          (section:create [&omicron=$passed-test])
        ] |
          section:merge |
          should-be (
            section:create [&omicron=$test-result:duplicate-test]
          )
      }

      >> 'when two tests at the same level have the same name and different outcomes' {
        all [
          (section:create [&omicron=$passed-test])
          (section:create [&omicron=$failed-test])
        ] |
          section:merge |
          should-be (
            section:create [&omicron=$test-result:duplicate-test]
          )
      }

      >> 'when there are multiple levels of tests' {
        all [
          $section-with-alpha
          (
            put $section-with-beta |
              section:add-sub-section sigma $section-with-gamma
          )
        ] |
          section:merge |
          should-be (
            section:create [&alpha=$alpha-test &beta=$beta-test] [&sigma=(section:create [&gamma=$gamma-test])]
          )
      }
    }

    >> 'with 3 operands' {
      all [
        $section-with-alpha
        $section-with-beta
        $section-with-gamma
      ] |
        section:merge |
        should-be (
          section:create [
            &alpha=$alpha-test
            &beta=$beta-test
            &gamma=$gamma-test
          ]
        )
    }
  }
}