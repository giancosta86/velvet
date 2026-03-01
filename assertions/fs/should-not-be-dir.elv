use os
use github.com/giancosta86/ethereal/v1/lang
use ../shared

var -error-message = 'should-not-be-dir assertion failed'

var should-not-be-dir~ = (
  shared:create-assertion-on-tested-entries (lang:negate $os:is-dir~) 'Non-missing directories' $-error-message
)
