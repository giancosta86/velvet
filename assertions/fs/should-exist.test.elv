use ./should-exist

var should-exist~ = $should-exist:should-exist~

>> 'Assertions' {
  >> 'file system' {
    >> 'should-exist' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        echo '' > alpha
        mkdir beta
        echo '' > gamma

        >> 'when the file system entries exist' {
          all [
            alpha
            beta
            gamma
          ] |
            should-exist
        }

        >> 'when some file system entries do not exist' {
          assertion-fails (src) {
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
        }
      }
    }
  }
}
