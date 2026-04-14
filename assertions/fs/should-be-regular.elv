use os
use ../shared

var should-be-regular~ = (
  src |
    shared:create-assertion-testing-entries $os:is-regular~ 'Missing files'
)
