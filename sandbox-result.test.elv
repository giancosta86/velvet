use str
use ./outcomes
use ./sandbox-result
use ./section
use ./test-result

>> 'Sandbox result' {
  >> 'creation' {
    var section = (
      section:create [
        &alpha=(
          test-result:success [Hello]
        )
      ]
    )

    var exception-lines-by-script = [
      &alpha.test.elv=[
        line-1
        line-2
        line-3
      ]
    ]

    >> 'when passing no values' {
      all [] |
        sandbox-result:create |
        should-be [
          &section=$section:empty
          &exception-lines-by-script=[&]
        ]
    }

    >> 'when passing just the section' {
      sandbox-result:create $section |
        should-be [
          &section=$section
          &exception-lines-by-script=[&]
        ]
    }

    >> 'when passing both the section and the exception lines' {
      sandbox-result:create $section $exception-lines-by-script |
        should-be [
          &section=$section
          &exception-lines-by-script=$exception-lines-by-script
        ]
    }

    >> 'from section' {
      put $section |
        sandbox-result:from-section |
        should-be (
          sandbox-result:create $section
        )
    }

    >> 'from exception' {
      var script-path = (src)[name]
      var exception = ?(fail DODO)

      var result = (
        sandbox-result:from-exception $script-path $exception
      )

      put $result[section] |
        should-be $section:empty

      all $result[exception-lines-by-script][$script-path] |
        str:join "\n" |
        should-contain-all [
          DODO
          $script-path
        ]
    }
  }

  >> 'merging' {
    var left = (
      sandbox-result:create (
        section:create [
          &test-from-left=(
            test-result:success ['Left test']
          )
        ]
      ) [
        &cip/ciop.test.elv=[
          alpha
          beta
          gamma
        ]
      ]
    )

    var right = (
      sandbox-result:create (
        section:create [
          &test-from-right=(
            test-result:failure ['Right test'] [Ex1 Ex2 Ex3]
          )
        ]
      ) [
          &yogi/bubu.test.elv=[
            ro
            sigma
          ]
          &park/ranger.test.elv=[
            line-1
            line-2
            line-3
            line-4
          ]
      ]
    )

    >> 'with no operands' {
      all [] |
        sandbox-result:merge |
          should-be $sandbox-result:empty
    }

    >> 'with 1 operand' {
      sandbox-result:merge $left |
        should-be $left
    }

    >> 'with 2 operands' {
      >> 'when both operands are empty' {
        sandbox-result:merge $sandbox-result:empty $sandbox-result:empty |
          should-be $sandbox-result:empty
      }

      >> 'when only the left operand is non-empty' {
        sandbox-result:merge $left $sandbox-result:empty |
          should-be $left
      }

      >> 'when only the right operand is non-empty' {
        sandbox-result:merge $sandbox-result:empty $right |
          should-be $right
      }

      >> 'when both operands are non-empty' {
        sandbox-result:merge $left $right |
          should-be (
            sandbox-result:create (
              section:create [
                &test-from-left=(
                  test-result:success ['Left test']
                )
                &test-from-right=(
                  test-result:failure ['Right test'] [Ex1 Ex2 Ex3]
                )
              ]
            ) [
              &cip/ciop.test.elv=[
                alpha
                beta
                gamma
              ]
              &yogi/bubu.test.elv=[
                ro
                sigma
              ]
              &park/ranger.test.elv=[
                line-1
                line-2
                line-3
                line-4
              ]
            ]
          )
      }
    }
  }
}