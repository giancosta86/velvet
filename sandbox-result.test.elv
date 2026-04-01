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

    var crashed-scripts = [
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
          &crashed-scripts=[&]
        ]
    }

    >> 'when passing just the section' {
      sandbox-result:create $section |
        should-be [
          &section=$section
          &crashed-scripts=[&]
        ]
    }

    >> 'when passing both the section and the crashed scripts' {
      sandbox-result:create $section $crashed-scripts |
        should-be [
          &section=$section
          &crashed-scripts=$crashed-scripts
        ]
    }
  }

  >> 'merging' {
    var left-result = (
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

    var right-result = (
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
      sandbox-result:merge $left-result |
        should-be $left-result
    }

    >> 'with 2 operands' {
      >> 'when both operands are empty' {
        sandbox-result:merge $sandbox-result:empty $sandbox-result:empty |
          should-be $sandbox-result:empty
      }

      >> 'when only the left operand is non-empty' {
        sandbox-result:merge $left-result $sandbox-result:empty |
          should-be $left-result
      }

      >> 'when only the right operand is non-empty' {
        sandbox-result:merge $sandbox-result:empty $right-result |
          should-be $right-result
      }

      >> 'when both operands are non-empty' {
        sandbox-result:merge $left-result $right-result |
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