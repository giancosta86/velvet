use github.com/giancosta86/ethereal/v1/lang
use ./sandbox-result
use ./section
use ./stats

fn from-sandbox-result { |@arguments|
  var sandbox-result = (lang:get-single-input $arguments)

  stats:from-section $sandbox-result[section] |
    assoc $sandbox-result stats (all)
}

var empty = (from-sandbox-result $sandbox-result:empty)

fn simplify { |@arguments|
  var summary = (lang:get-single-input $arguments)

  section:simplify $summary[section] |
    assoc $summary section (all)
}
