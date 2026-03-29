use ../../section
use ../../summary
use ../../test-result

var alpha = (summary:from-sandbox-result [
  &section=(
    section:create [&] [
      &'In alpha'=(
        section:create [&'should work'=(test-result:success ['Alpha 1'])]
      )
    ]
  )
  &crashed-scripts=[&]
])

var alpha-beta = (summary:from-sandbox-result [
  &section=(
    section:create [&] [
      &'In alpha'=(
        section:create [
          &'should work'=(test-result:success ['Alpha 1'])
        ] [
          &'In sub-level'=(
            section:create [&] [
              &'In sub-sub-level'=(
                section:create [&'should be ok'=(test-result:success ['Alpha X'])]
              )
            ]
          )
        ]
      )
      &'In beta'=(
        section:create [&'has duplicate in third source file'=(test-result:success ['Beta 2'])]
      )
    ]
  )
  &crashed-scripts=[&]
])

var alpha-beta-gamma-simplified = (summary:from-sandbox-result [
  &section=(
    section:create [&] [
      &'In alpha'=(
        section:create [
          &'should work'=(test-result:success ['Alpha 1'])
          &'should work too'=(test-result:success ['Alpha 5'])
        ] [
          &'In sub-level'=(
            section:create [
              &'should fail'=(test-result:failure [Cip Ciop] [])
            ] [
              &'In sub-sub-level'=(
                section:create [&'should be ok'=(test-result:success ['Alpha X'])]
              )
            ]
          )
        ]
      )
      &'In beta'=(
        section:create [
          &'has duplicate in third source file'=(test-result:failure [] [])
        ]
      )
      &'In gamma'=(
        section:create [
          &'should pass'=(test-result:success ['Gamma 3'])
        ]
      )
    ]
  )
  &crashed-scripts=[&]
])