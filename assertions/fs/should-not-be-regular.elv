use os
use github.com/giancosta86/ethereal/v1/lang
use ../shared

var should-not-be-regular~ = (
  src |
    shared:create-assertion-testing-entries (lang:negate $os:is-regular~) 'Non-missing files'
)
