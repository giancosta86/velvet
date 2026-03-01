use os
use ../shared

var -error-message = 'should-be-dir assertion failed'

var should-be-dir~ = (
  shared:create-assertion-on-tested-entries $os:is-dir~ 'Missing directories' $-error-message
)
