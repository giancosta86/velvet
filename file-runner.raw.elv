use ./outcomes
use ./raw
use ./file-runner

raw:suite 'Testing a single file runner' { |test~ assert~|
  var result = (file-runner:run ./tests/basic.elv)

  pprint $result

  var outcome-context = $result[outcome-context]

  test 'The stats must be valid' {
    var stats = $result[stats]
    assert $stats[is-ok] 'is-ok should be true!'
    assert (eq $stats[total-failed] (num 0)) 'total-failed should be 0!'
    assert (eq $stats[total-passed] (num 3)) 'total-passed should be 3!'
    assert (eq $stats[total-tests] (num 3)) 'total-tests should be 3!'
  }

  test 'The outcomes must be successful' {  {
    assert (eq $outcome-context['Basic standalone test'][outcomes]['should run'] $outcomes:passed) 'The root outcome should be OK!'

     assert (eq $outcome-context['Basic standalone test'][sub-contexts]['in sub-describe'][outcomes]['should support yet another test'] $outcomes:passed) 'The first sub-outcome should be OK!'

     assert (eq $outcome-context['Basic standalone test'][sub-contexts]['in sub-describe'][outcomes]['should work, too'] $outcomes:passed) 'The other sub-outcome should be OK!'
  }

  test 'The final sub-contexts should be empty' {
    assert (eq $outcome-context['Basic standalone test'][sub-contexts]['in sub-describe'][sub-contexts] [&]) 'Sub-contexts should be missing'
  }
  }
}
