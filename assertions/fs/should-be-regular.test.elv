use ../../block-handlers/assertion-fails
use ./should-be-regular

var assertion-fails~ = $assertion-fails:assertion-fails~
var should-be-regular~ = $should-be-regular:should-be-regular~

>> 'Assertions: should-be-regular' {
  fs:with-temp-dir { |temp-dir|
    cd $temp-dir

    echo Alpha > alpha
    echo Beta > beta
    echo Gamma > gamma

    >> 'when the files exist' {
      put alpha |
        should-be-regular

      all [
        alpha
        beta
        gamma
      ] |
        should-be-regular
    }

    >> 'when some files do not exist' {
      var failing-assertion = {
        all [
          alpha
          ro
          beta
          sigma
          tau
          gamma
        ] |
          should-be-regular
      }

      >> 'should fail' {
        assertion-fails (src) {
          $failing-assertion
        }
      }
    }
  }
}