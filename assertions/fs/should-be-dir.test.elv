use os
use ../../block-handlers/assertion-fails
use ./should-be-dir

var assertion-fails~ = $assertion-fails:assertion-fails~
var should-be-dir~ = $should-be-dir:should-be-dir~

>> 'Assertions: should-be-dir' {
  fs:with-temp-dir { |temp-dir|
    cd $temp-dir

    os:mkdir alpha
    os:mkdir beta
    os:mkdir gamma

    >> 'when the directories exist' {
      all [
        alpha
        beta
        gamma
      ] |
        should-be-dir
    }

    >> 'when some directories do not exist' {
      var failing-assertion = {
        all [
          alpha
          ro
          beta
          sigma
          tau
          gamma
        ] |
          should-be-dir
      }

      >> 'should fail' {
        assertion-fails (src) {
          $failing-assertion
        }
      }
    }
  }
}