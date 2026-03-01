use os
use ./should-not-be-dir

var should-not-be-dir~ = $should-not-be-dir:should-not-be-dir~

>> 'Assertions: should-not-be-dir' {
  fs:with-temp-dir { |temp-dir|
    cd $temp-dir

    os:mkdir alpha
    os:mkdir beta
    os:mkdir gamma

    >> 'when the directories are missing' {
      all [
        ro
        sigma
      ] |
        should-not-be-dir
    }

    >> 'when some directories actually exist' {
      var failing-assertion = {
        all [
          alpha
          ro
          beta
          sigma
          tau
          gamma
        ] |
          should-not-be-dir
      }

      >> 'should fail' {
        fails {
          $failing-assertion
        } |
          should-be $should-not-be-dir:-error-message
      }

      >> 'should display just such directories' {
        var output-tester = (
          throws &swallow {
            $failing-assertion
          } |
            create-output-tester &unstyled
        )

        $output-tester[should-contain-all] [
          'Non-missing directories'
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