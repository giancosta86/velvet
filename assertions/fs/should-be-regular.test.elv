use ./should-be-regular

var should-be-regular~ = $should-be-regular:should-be-regular~

>> 'Assertions' {
  >> 'file system' {
    >> 'should-be-regular' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        echo Alpha > alpha
        echo Beta > beta
        echo Gamma > gamma

        >> 'when the files exist' {
          all [
            alpha
            beta
            gamma
          ] |
            should-be-regular
        }

        >> 'when some files do not exist' {
          assertion-fails (src) {
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
        }
      }
    }
  }
}
