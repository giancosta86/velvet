use ./should-not-be-regular

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
        fails {
          $failing-assertion
        } |
          should-be $should-not-be-regular:-error-message
      }

      >> 'should display just such files' {
        var output-tester = (
          throws &swallow {
            $failing-assertion
          } |
            create-output-tester &unstyled
        )

        $output-tester[should-contain-all] [
          'Non-missing files'
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