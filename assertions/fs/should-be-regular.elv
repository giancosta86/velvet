use os
use ../shared

var -error-message = 'should-be-regular assertion failed'

var should-be-regular~ = (
  shared:create-assertion-on-tested-entries $os:is-regular~ 'Missing files' $-error-message
)
