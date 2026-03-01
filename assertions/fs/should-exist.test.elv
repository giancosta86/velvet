use ./should-exist

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
        fails {
          $failing-assertion
        } |
          should-be $should-exist:-error-message
      }

      >> 'should display just such file system entries' {
        var output-tester = (
          throws &swallow {
            $failing-assertion
          } |
            create-output-tester &unstyled
        )

        $output-tester[should-contain-all] [
          'Missing file system entries'
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