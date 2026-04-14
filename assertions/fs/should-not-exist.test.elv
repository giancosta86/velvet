use os
use ../assertion-fails
use ./should-not-exist

var assertion-fails~ = $assertion-fails:assertion-fails~
var should-not-exist~ = $should-not-exist:should-not-exist~

>> 'Assertions: should-not-exist' {
  fs:with-temp-dir { |temp-dir|
    cd $temp-dir

    echo Alpha > alpha
    os:mkdir beta
    echo Gamma > gamma

    >> 'when the file system entries are missing' {
      all [
        ro
        sigma
      ] |
        should-not-exist
    }

    >> 'when some file system entries actually exist' {
      var failing-assertion = {
        all [
          alpha
          ro
          beta
          sigma
          tau
          gamma
        ] |
          should-not-exist
      }

      >> 'should fail' {
        assertion-fails (src) {
          $failing-assertion
        }
      }

      >> 'should display just such file system entries' {
        var output-tester = (
          throws &swallow {
            $failing-assertion
          } |
            create-output-tester &unstyled
        )

        $output-tester[should-contain-all] [
          'Non-missing file system entries'
          alpha
          beta
          gamma
        ]

        $output-tester[should-contain-none] [
          ro
          sigma
          tau
        ]
      }
    }
  }
}