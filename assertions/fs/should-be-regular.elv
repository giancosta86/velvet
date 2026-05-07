use os
use ../../assertion

fn should-be-regular {
  assertion:enforce-predicate (src) $os:is-regular~ 'Missing files'
}
