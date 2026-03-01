use os
use github.com/giancosta86/ethereal/v1/lang
use ../shared

var -error-message = 'should-not-be-regular assertion failed'

var should-not-be-regular~ = (
  shared:create-assertion-on-tested-entries (lang:negate $os:is-regular~) 'Non-missing files' $-error-message
)
