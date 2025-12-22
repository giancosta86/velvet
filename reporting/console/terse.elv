use ../../section
use ./shared

fn report { |summary|
  put [
    &section=(section:keep-failed-test-results $summary[section])
    &stats=$summary[stats]
    &crashed-scripts=$summary[crashed-scripts]
  ] |
    shared:report (all)
}