use ../../section
use ./shared

fn report { |summary|
  put $summary[section] |
    section:keep-failed-test-results |
    assoc $summary section (all) |
    shared:report (all)
}