use ./should-not-be-regular

var should-not-be-regular~ = $should-not-be-regular:should-not-be-regular~

>> 'Assertions' {
  >> 'file system' {
    >> 'should-not-be-regular' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        echo '' > alpha
        echo '' > beta
        echo '' > gamma

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
