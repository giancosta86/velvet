use path
use github.com/giancosta86/aurora-elvish/command
use github.com/giancosta86/aurora-elvish/exception
use ../aggregator
use ../assertions
use ../outcomes
use ../raw
use ./cli

raw:suite 'CLI reporting' { |test~|
  test 'With empty describe result' {
    cli:display [
      &test-results=[&]
      &sub-results=[&]
    ] |
      assertions:should-be '💬 No test structure found.'
  }

  test 'With single passed test' {
    cli:display [
      &test-results=[
        &Alpha=[
          &outcome=$outcomes:passed
          &output="Wiii!\n"
          &exception-log=$nil
        ]
      ]
      &sub-results=[&]
    ] |
      slurp |
      assertions:should-be (styled Alpha bold green)' '✅"\n"
  }

  test 'With single failed test' {
    cli:display [
      &test-results=[
        &Beta=[
          &outcome=$outcomes:failed
          &output="Wooo!\n"
          &exception-log="DODO"
        ]
      ]
      &sub-results=[&]
    ] |
      slurp |
      assertions:should-be (styled Beta bold red)' '❌"\nWooo!\n\nDODO\n"
  }

  test 'With multi-level describe result' {
    var script-directory = (path:dir (src)[name])
    var describe-result = (aggregator:run-test-scripts (path:join $script-directory .. tests aggregator)/*.test.elv)

    cli:display $describe-result
  }
}