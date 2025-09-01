use github.com/giancosta86/aurora-elvish/hash-set
use ./raw
use ./describe-context

raw:suite 'Testing a describe context' { |test~ assert~|
  test 'Creating empty root' {
    var root = (describe-context:create-root 'Alpha')

    var outcome-context = ($root[to-outcome-context])

    assert (eq $outcome-context[outcomes] [&])
    assert (eq $outcome-context[sub-contexts] [&])
  }

  test 'Creating a new sub-context' {
    var root = (describe-context:create-root 'Alpha')

    $root[ensure-sub-context] 'Beta'

    var outcome-context = ($root[to-outcome-context])

    assert (hash-set:equals $outcome-context[sub-contexts] [Beta])
  }
}