use ./should-be-regular

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
        fails {
          $failing-assertion
        } |
          should-be $should-be-regular:-error-message
      }

      >> 'should display just such files' {
        var output-tester = (
          throws &swallow {
            $failing-assertion
          } |
            create-output-tester &unstyled
        )

        $output-tester[should-contain-all] [
          'Missing files'
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