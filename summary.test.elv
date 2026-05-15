use ./outcomes
use ./sandbox-result
use ./section
use ./summary
use ./test-result

var exception-lines-by-script = [
  &park/yogi.test.elv=[
    alpha
    beta
    gamma
  ]
]

>> 'Summary' {
  >> 'creation from sandbox result' {
    var section = (
      section:create [
        &alpha=(
          test-result:success []
        )
      ] [
        &beta=(
          section:create [
            &gamma=(
              test-result:success []
            )
            &delta=(
              test-result:failure [] []
            )
          ] [
            &epsilon=(
              section:create [
                &zeta=$test-result:duplicate-test
                &eta=(
                  test-result:success []
                )
              ]
            )
          ]
        )
      ]
    )

    sandbox-result:create $section $exception-lines-by-script |
      summary:from-sandbox-result |
      should-be [
        &section=$section
        &stats=[
          &total=5
          &passed=3
          &failed=2
        ]
        &exception-lines-by-script=$exception-lines-by-script
      ]
  }

  >> 'simplification' {
    var section = (
      section:create [
        &Yogi=(
          test-result:success [Wiii!]
        )
      ] [
        &Cip=(
          section:create [
            &Bubu=(
              test-result:failure [Wooo!] [DODO]
            )
          ] [
            &Ciop=(
              section:create [
                &Ranger=$test-result:duplicate-test
              ]
            )
          ]
        )
      ]
    )

    sandbox-result:create $section $exception-lines-by-script |
      summary:from-sandbox-result |
      summary:simplify |
      should-be [
        &section=(section:simplify $section)
        &stats=[
          &total=3
          &passed=1
          &failed=2
        ]
        &exception-lines-by-script=$exception-lines-by-script
      ]
  }
}
