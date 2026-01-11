use ./section
use ./stats

var empty = [
  &section=$section:empty
  &stats=$stats:empty
  &crashed-scripts=[&]
]

fn from-sandbox-result { |sandbox-result|
  var section = $sandbox-result[section]
  var stats = (stats:from-section $section)

  put [
    &section=$section
    &stats=$stats
    &crashed-scripts=$sandbox-result[crashed-scripts]
  ]
}

fn simplify { |summary|
  put [
    &section=(section:simplify $summary[section])
    &stats=$summary[stats]
    &crashed-scripts=$summary[crashed-scripts]
  ]
}
