use github.com/giancosta86/ethereal/v1/lang
use ./section
use ./stats

var empty = [
  &section=$section:empty
  &stats=$stats:empty
  &crashed-scripts=[&]
]

fn from-sandbox-result { |@arguments|
  var sandbox-result = (lang:get-single-input $arguments)

  stats:from-section $sandbox-result[section] |
    assoc $sandbox-result stats (all)
}

fn simplify { |@arguments|
  var summary = (lang:get-single-input $arguments)

  section:simplify $summary[section] |
    assoc $summary section (all)
}
