use ../../block-handlers/assertion-fails
use ./should-not-be-regular

var assertion-fails~ = $assertion-fails:assertion-fails~
var should-not-be-regular~ = $should-not-be-regular:should-not-be-regular~

>> 'Assertions: should-not-be-regular' {
  fs:with-temp-dir { |temp-dir|
    cd $temp-dir

    echo Alpha > alpha
    echo Beta > beta
    echo Gamma > gamma

    >> 'when the files are missing' {
      all [
        ro
        sigma
      ] |
        should-not-be-regular
    }

    >> 'when some files actually exist' {
      var failing-assertion = {
        all [
          alpha
          ro
          beta
          sigma
          tau
          gamma
        ] |
          should-not-be-regular
      }

      >> 'should fail' {
        assertion-fails (src) {
          $failing-assertion
        }
      }
    }
  }
}