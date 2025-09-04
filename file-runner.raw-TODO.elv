use github.com/giancosta86/aurora-elvish/hash-set
use ./raw
use ./outcomes
use ./file-runner


raw:suite 'Testing a single file runner' { |test~ assert~|
  var result = (file-runner:run ./tests/basic.elv)

  var result-context = $result[result-context]

  test 'The stats should be valid' {
    var stats = $result[stats]
    assert $stats[is-ok]
    assert (eq $stats[total-failed] (num 0))
    assert (eq $stats[total-passed] (num 3))
    assert (eq $stats[total-tests] (num 3))
  }

  test 'The outcomes should be successful' {
    assert (eq $result-context[sub-contexts]['Basic standalone test'][outcomes]['should run'] $outcomes:passed)

     assert (eq $result-context[sub-contexts]['Basic standalone test'][sub-contexts]['in sub-describe'][outcomes]['should support yet another test'] $outcomes:passed)

     assert (eq $result-context[sub-contexts]['Basic standalone test'][sub-contexts]['in sub-describe'][outcomes]['should work, too'] $outcomes:passed)
  }

  test 'The sub-contexts should be the expected ones' {
    assert (hash-set:equals $result-context[sub-contexts] ['Basic standalone test'])

    assert (hash-set:equals $result-context[sub-contexts]['Basic standalone test'][sub-contexts] ['in sub-describe'])
  }

  test 'The leaf sub-contexts should be empty' {
    assert (eq $result-context[sub-contexts]['Basic standalone test'][sub-contexts]['in sub-describe'][sub-contexts] [&])
  }
}
