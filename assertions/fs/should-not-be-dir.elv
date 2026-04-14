use os
use github.com/giancosta86/ethereal/v1/lang
use ../shared

var should-not-be-dir~ = (
  src |
    shared:create-assertion-testing-entries (lang:negate $os:is-dir~) 'Non-missing directories'
)
