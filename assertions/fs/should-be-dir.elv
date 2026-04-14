use os
use ../shared

var should-be-dir~ = (
  src |
    shared:create-assertion-testing-entries $os:is-dir~ 'Missing directories'
)
