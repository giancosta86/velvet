use os
use ./should-not-exist

var should-not-exist~ = $should-not-exist:should-not-exist~

>> 'Assertions' {
  >> 'file system' {
    >> 'should-not-exist' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        fs:touch alpha
        os:mkdir beta
        fs:touch gamma

        >> 'when the file system entries are missing' {
          all [
            ro
            sigma
          ] |
            should-not-exist
        }

        >> 'when a file actually exists' {
          assertion-fails (src) {
            all [
              ro
              alpha
              sigma
            ] |
              should-not-exist
          }
        }

        >> 'when a directory actually exists' {
          assertion-fails (src) {
            all [
              ro
              beta
              sigma
            ] |
              should-not-exist
          }
        }
      }
    }
  }
}
