use os
use github.com/giancosta86/ethereal/v1/lang
use ../../assertion

fn should-not-be-regular {
  assertion:enforce-predicate (src) (lang:negate $os:is-regular~) 'Non-missing files'
}
