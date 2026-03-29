use ./outcomes
use ./section
use ./summary
use ./test-result

var crashed-scripts = [
  &park/yogi.test.elv=[
    alpha
    beta
    gamma
  ]
]

>> 'Summary' {
  >> 'creation from sandbox result' {
    var section = (
      section:create [&alpha=(test-result:success [])] [
        &beta=(
          section:create [
            &gamma=(test-result:success [])
            &delta=(test-result:failure [] [])
          ] [
            &epsilon=(
              section:create [
                &zeta=$test-result:duplicate-test
                &eta=(test-result:success [])
              ]
            )
          ]
        )
      ]
    )

    var sandbox-result = [
      &section=$section
      &crashed-scripts=$crashed-scripts
    ]

    summary:from-sandbox-result $sandbox-result |
      should-be [
        &section=$section
        &stats=[
          &total=5
          &passed=3
          &failed=2
        ]
        &crashed-scripts=$crashed-scripts
      ]
  }

  >> 'simplification' {
    var section = (
      section:create [
        &Yogi=(test-result:success [Wiii!])
      ] [
        &Cip=(
          section:create [
            &Bubu=(test-result:failure [Wooo!] (show ?(fail DODO) | slurp))
          ] [
            &Ciop=(
              section:create [&Ranger=$test-result:duplicate-test]
            )
          ]
        )
      ]
    )

    var sandbox-result = [
      &section=$section
      &crashed-scripts=$crashed-scripts
    ]

    put $sandbox-result |
      summary:from-sandbox-result |
      summary:simplify |
      should-be [
        &section=(section:simplify $section)
        &stats=[
          &total=3
          &passed=1
          &failed=2
        ]
        &crashed-scripts=$crashed-scripts
      ]
  }
}
