use os
use github.com/giancosta86/ethereal/v1/lang
use ../shared

var should-not-exist~ = (
  src |
    shared:create-assertion-testing-entries (lang:negate $os:exists~) 'Non-missing file system entries'
)
