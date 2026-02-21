use str
use github.com/giancosta86/ethereal/v1/command
use ./exception-lines

>> 'Exception lines - trimming clockwork stack' {
  >> 'with no lines' {
    all [] |
      exception-lines:trim-clockwork-stack |
      put [(all)] |
      should-be []
  }

  >> 'with stack referencing Ethereal''s command' {
    all [
      Alpha
      Beta
      Gamma
      github.com/giancosta86/ethereal/v1/command.elv:10:11-22
      CLOCKWORK 1
      CLOCKWORK 2
    ] |
      exception-lines:trim-clockwork-stack |
      put [(all)] |
      should-be [
        Alpha
        Beta
        Gamma
      ]
  }

  >> 'with hand-made exception referencing test-script from a specific Velvet version' {
    all [
      '[eval 1]:8:9-12: var v = $asd'
      Ro
      Sigma
      'github.com/giancosta86/velvet/v3/test-script.elv:34'
      SomeOtherLine
      '~/.local/share/elvish/lib/github.com/giancosta86/velvet/v3/sandbox.elv:7:3-25:   each $test-script:run~ |'
    ] |
      exception-lines:trim-clockwork-stack |
      put [(all)] |
      should-be [
        '[eval 1]:8:9-12: var v = $asd'
        Ro
        Sigma
      ]
  }

  >> 'with hand-made exception referencing Velvet''s working directory' {
    all [
      '[eval 1]:8:9-12: var v = $asd'
      Ro
      Sigma
      ~'/fake-project-dir/velvet/test-script.elv:34'
      SomeOtherLine
      '~/.local/share/elvish/lib/github.com/giancosta86/velvet/v3/sandbox.elv:7:3-25:   each $test-script:run~ |'
    ] |
      exception-lines:trim-clockwork-stack |
      put [(all)] |
      should-be [
        '[eval 1]:8:9-12: var v = $asd'
        Ro
        Sigma
      ]
  }

  >> 'with stack obtained from command capturing' {
    var capture-result = (
      command:capture {
        fail DODUS
      }
    )

    show $capture-result[exception] |
      exception-lines:trim-clockwork-stack |
      str:join "\n" |
      str:contains (all) command.elv |
      should-be $false
  }
}

>> 'Exception lines - replacing eval' {
  >> 'with no lines' {
    all [] |
      exception-lines:replace-bottom-eval ciop.elv |
      put [(all)] |
      should-be []
  }

  >> 'with no eval' {
    var lines = [
      Alpha
      Beta
      Gamma
    ]

    all $lines |
      exception-lines:replace-bottom-eval ciop.elv |
      put [(all)] |
      should-be $lines
  }

  >> 'with single bottom eval' {
    all [
      Alpha
      Beta
      '[eval 123]:45:8-11: Fake error'
    ] |
      exception-lines:replace-bottom-eval ciop.elv |
      put [(all)] |
      should-be [
        Alpha
        Beta
        'ciop.elv:45:8-11: Fake error'
      ]
  }

  >> 'with different initial spaces for same eval' {
    all [
      Alpha
      Beta
      '[eval 123]:65:4-18: Alpha'
      ' [eval 123]:23:7-13: Beta'
      '  [eval 123]:45:8-11: Gamma'
    ] |
      exception-lines:replace-bottom-eval ciop.elv |
      put [(all)] |
      should-be [
        Alpha
        Beta
        'ciop.elv:65:4-18: Alpha'
        ' ciop.elv:23:7-13: Beta'
        '  ciop.elv:45:8-11: Gamma'
      ]
  }

  >> 'with multiple instances of eval' {
    all [
      Alpha
      Beta
      '[eval 123]:12:15:17-23: First eval here'
      '[eval 456]:123:7: Yet another fake error'
      '[eval 123]:80:3:4-67: Another fake error'
      Gamma
      '[eval 123]:45:8-11: Fake error'
      Delta
    ] |
      exception-lines:replace-bottom-eval ciop.elv |
      put [(all)] |
      should-be [
        Alpha
        Beta
        'ciop.elv:12:15:17-23: First eval here'
        '[eval 456]:123:7: Yet another fake error'
        'ciop.elv:80:3:4-67: Another fake error'
        Gamma
        'ciop.elv:45:8-11: Fake error'
        Delta
      ]
  }

  >> 'with eval call within command capturing' {
    var capture-result = (command:capture {
      var code = '
        fn beta {
          fail DODO
        }

        fn alpha {
          beta
        }

        alpha
      '

      eval $code
    })

    var exception-log = (
      show $capture-result[exception] |
        exception-lines:trim-clockwork-stack |
        exception-lines:replace-bottom-eval ciop.elv |
        str:join "\n"
    )

    str:contains $exception-log DODO |
      should-be $true

    str:contains $exception-log ciop.elv |
      should-be $true
  }
}