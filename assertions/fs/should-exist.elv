use os
use ../shared

var should-exist~ = (
  src |
    shared:create-assertion-testing-entries $os:exists~ 'Missing file system entries'
)
