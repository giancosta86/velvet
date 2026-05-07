use ../../block-handlers/assertion-fails
use ./should-exist

var assertion-fails~ = $assertion-fails:assertion-fails~
var should-exist~ = $should-exist:should-exist~

>> 'Assertions: should-exist' {
  fs:with-temp-dir { |temp-dir|
    cd $temp-dir

    echo Alpha > alpha
    mkdir beta
    echo Gamma > gamma

    >> 'when the file system entries exist' {
      all [
        alpha
        beta
        gamma
      ] |
        should-exist
    }

    >> 'when some file system entries do not exist' {
      var failing-assertion = {
        all [
          alpha
          ro
          beta
          sigma
          tau
          gamma
        ] |
          should-exist
      }

      >> 'should fail' {
        assertion-fails (src) {
          $failing-assertion
        }
      }
    }
  }
}