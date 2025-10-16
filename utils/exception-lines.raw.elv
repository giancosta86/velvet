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
      exception-lines:replace-bottom-eval '<CIOP>' |
      eq [(all)] [] |
      assertion:assert (all)
  }
}