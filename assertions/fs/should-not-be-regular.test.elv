use ./should-not-be-regular

var should-not-be-regular~ = $should-not-be-regular:should-not-be-regular~

>> 'Assertions' {
  >> 'file system' {
    >> 'should-not-be-regular' {
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
          assertion-fails (src) {
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
        }
      }
    }
  }
}
