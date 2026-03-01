use os
use github.com/giancosta86/ethereal/v1/lang
use ../shared

var -error-message = 'should-not-exist assertion failed'

var should-not-exist~ = (
  shared:create-assertion-on-tested-entries (lang:negate $os:exists~) 'Non-missing file system entries' $-error-message
)
