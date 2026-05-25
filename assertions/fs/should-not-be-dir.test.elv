use os
use ./should-not-be-dir

var should-not-be-dir~ = $should-not-be-dir:should-not-be-dir~

>> 'Assertions' {
  >> 'file system' {
    >> 'should-not-be-dir' {
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
          assertion-fails (src) {
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
        }
      }
    }
  }
}
