use ./run-dual

>> 'Assertion: running the dual script' {
  >> 'when getting the dual script path' {
    run-dual:-get-dual-script '/alpha/beta/gamma.test.elv' |
      should-be '/alpha/beta/gamma.elv'
  }

  >> 'when running the dual script' {
    var fake-test-script = my-script.test.elv

    var fake-dual-script = my-script.elv

    fn fake-src {
      put [
        &name=$fake-test-script
      ]
    }

    fs:with-temp-dir { |temp-dir|
      cd $temp-dir

      >> 'when the dual script is ok' {
        echo 'echo Hello' > $fake-dual-script

        fake-src |
          run-dual:run-dual |
          should-be Hello
      }

      >> 'when the dual script is broken' {
        echo 'use ./MISSING-MODULE' > $fake-dual-script

        var reason = (
          throws {
            run-dual:run-dual (fake-src)
          } |
            put (all)[reason]
        )

        put $reason[cmd-name] |
          should-be 'elvish'
      }
    }
  }
}