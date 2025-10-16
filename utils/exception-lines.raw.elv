use str
use ./assertion
use ./command
use ./exception-lines
use ./raw

raw:suite 'Exception lines - trimming clockwork stack' { |test~|
  test 'With no lines' {
    all [] |
      exception-lines:trim-clockwork-stack |
      eq [(all)] [] |
      assertion:assert (all)
  }

  test 'With hand-made clockwork stack' {
    all [
      Alpha
      Beta
      Gamma
      giancosta86/velvet/utils/command.elv:11:9-14
      CLOCKWORK 1
      CLOCKWORK 2
    ] |
      exception-lines:trim-clockwork-stack |
      eq [(all)] [
        Alpha
        Beta
        Gamma
      ] |
      assertion:assert (all)
  }

  test 'With stack induced by command capturing' {
    var capture-result = (
      command:capture {
        fail DODUS
      }
    )

    show $capture-result[exception] |
      exception-lines:trim-clockwork-stack |
      str:join "\n" |
      str:contains (all) command.elv |
      not (all) |
      assertion:assert (all)
  }
}


raw:suite 'Exception lines - replacing eval' { |test~|
  test 'With no lines' {
    all [] |
      exception-lines:replace-bottom-eval ciop.elv |
      eq [(all)] [] |
      assertion:assert (all)
  }

  test 'With no eval' {
    var lines = [
      Alpha
      Beta
      Gamma
    ]

    all $lines |
      exception-lines:replace-bottom-eval ciop.elv |
      eq [(all)] $lines |
      assertion:assert (all)
  }

  test 'With single bottom eval' {
    all [
      Alpha
      Beta
      '[eval 123]:45:8-11: Fake error'
    ] |
      exception-lines:replace-bottom-eval ciop.elv |
      eq [(all)] [
        Alpha
        Beta
        'ciop.elv:45:8-11: Fake error'
      ] |
      assertion:assert (all)
  }

  test 'With multiple instances of eval' {
    all [
      Alpha
      Beta
      '[eval 456]:123:7: Yet another fake error'
      '[eval 123]:80:3:4-67: Another fake error'
      Gamma
      '[eval 123]:45:8-11: Fake error'
      Delta
    ] |
      exception-lines:replace-bottom-eval ciop.elv |
      eq [(all)] [
        Alpha
        Beta
        '[eval 456]:123:7: Yet another fake error'
        'ciop.elv:80:3:4-67: Another fake error'
        Gamma
        'ciop.elv:45:8-11: Fake error'
        Delta
      ] |
      assertion:assert (all)
  }

  test 'With eval not at the beginning of the line' {
    all [
      Alpha
      Beta
      '[eval 456]:123:7: Yet another fake error, but not in [eval 123]'
      '[eval 123]:80:3:4-67: Another fake error'
      Gamma
      '[eval 123]:45:8-11: Fake error'
      Delta
    ] |
      exception-lines:replace-bottom-eval ciop.elv |
      eq [(all)] [
        Alpha
        Beta
        '[eval 456]:123:7: Yet another fake error, but not in [eval 123]'
        'ciop.elv:80:3:4-67: Another fake error'
        Gamma
        'ciop.elv:45:8-11: Fake error'
        Delta
      ] |
      assertion:assert (all)
  }

  test 'With bottom eval induced by command capturing' {
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
        take 4 |
        exception-lines:replace-bottom-eval ciop.elv |
        str:join "\n"
    )

    str:contains $exception-log DODO |
      assertion:assert (all)

    str:contains $exception-log '[eval' |
      not (all) |
      assertion:assert (all)

    str:contains $exception-log ciop.elv |
      assertion:assert (all)
  }
}