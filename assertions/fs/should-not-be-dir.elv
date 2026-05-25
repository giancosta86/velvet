use os
use github.com/giancosta86/ethereal/v1/lang
use ../../assertion

fn should-not-be-dir {
  assertion:enforce-predicate (src) (lang:negate $os:is-dir~) 'Non-missing directories'
}
