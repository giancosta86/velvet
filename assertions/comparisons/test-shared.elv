use ../../assertion
use ../../block-handlers

var assertion-fails~ = $block-handlers:assertion-fails~

fn run-comparison-tests { |settings|
  var '>>~' = $settings['>>~']

  var assertion-reference = $settings[assertion-reference]

  var assertion-name = (assertion:get-name $assertion-reference)

  var assertion-module = (use-mod './'$assertion-name)

  var assertion = $assertion-module[$assertion-name'~']

  fn expect-assertion-status { |expected-status block|
    if (eq $expected-status pass) {
      $block
    } elif (eq $expected-status fail) {
      assertion-fails $assertion-name $block
    } else {
      fail 'Unknown assertion status: '$expected-status
    }
  }

  >> 'Assertions' {
    >> 'comparisons' {
      >> $assertion-name {
        >> 'with numbers' {
          >> 'when subject == boundary' {
            expect-assertion-status $settings[status][subject-equal] {
              put (num 90) |
                $assertion 90
            }
          }

          >> 'when subject > boundary' {
            expect-assertion-status $settings[status][subject-greater] {
              put (num 90) |
                $assertion 7
            }
          }

          >> 'when subject < boundary' {
            expect-assertion-status $settings[status][subject-less] {
              put (num 90) |
                $assertion (num 92)
            }
          }
        }

        >> 'with strings' {
          >> 'when subject == boundary' {
            expect-assertion-status $settings[status][subject-equal] {
              put gamma |
                $assertion gamma
            }
          }

          >> 'when subject > boundary' {
            expect-assertion-status $settings[status][subject-greater] {
              put gamma |
                $assertion alpha
            }
          }

          >> 'when subject < boundary' {
            expect-assertion-status $settings[status][subject-less] {
              put gamma |
                $assertion zeta
            }
          }

          >> 'when the boundary is a number' {
            >> 'when subject == boundary' {
              expect-assertion-status $settings[status][subject-equal] {
                put 90 |
                  $assertion (num 90)
              }
            }

            >> 'when subject > boundary' {
              expect-assertion-status $settings[status][subject-greater] {
                put 92 |
                  $assertion (num 90)
              }
            }

            >> 'when subject < boundary' {
              expect-assertion-status $settings[status][subject-less] {
                put 90 |
                  $assertion (num 92)
              }
            }
          }
        }
      }
    }
  }
}