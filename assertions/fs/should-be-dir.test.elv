use os
use ./should-be-dir

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
        fails {
          $failing-assertion
        } |
          should-be $should-be-dir:-error-message
      }

      >> 'should display just such directories' {
        var output-tester = (
          throws &swallow {
            $failing-assertion
          } |
            create-output-tester &unstyled
        )

        $output-tester[should-contain-all] [
          'Missing directories'
          ro
          sigma
          tau
        ]

        $output-tester[should-contain-none] [
          alpha
          beta
          gamma
        ]
      }
    }
  }
}