use ../../section
use ./shared

fn report { |summary|
  put $summary[section] |
    section:trim-passed-test-results |
    assoc $summary section (all) |
    shared:report (all)
}