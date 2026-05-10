use builtin
use github.com/giancosta86/ethereal/v1/fs
use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/seq
use ./utils/output

var failure-prefix = 'Assertion failed: '

#
# Creates an assertion-specific failure message having a recognizable prefix.
#
# This function is designed for fairly specific uses all over the codebase:
# instead of using it directly, you should call the assertion-specific `fail` function instead.
#
fn format-failure { |@arguments|
  var assertion-reference = (lang:get-single-input $arguments)

  var assertion-name = (
    if (eq (kind-of $assertion-reference) map) {
      put $assertion-reference[name] |
        fs:get-script-subject
    } else {
      put $assertion-reference
    }
  )

  put $failure-prefix''$assertion-name
}

#
# Gets a single input (via pipe or as argument) - the assertion reference - which can be:
#
# - the name of the assertion command itself (e.g.: «should-be»)
#
# - the output of the `src` command within the assertion script or its related test script
#
# and invokes the builtin `fail` function, with a message having a recognizable prefix.
#
fn fail { |@arguments|
  format-failure $@arguments |
    builtin:fail (all)
}

#
# Given an input `value` - passed via pipe or as argument:
#
# * if `&strict` is enabled, returns `value` itself
#
# * otherwise, returns the outcome of `lang:flat-num` applied to `value`
#
fn get-input { |&strict=$false @arguments|
  var value = (lang:get-single-input $arguments)

  if $strict {
    put $value
  } else {
    lang:flat-num $value
  }
}

#
# Enforces the given predicate on every value passed via pipe.
#
# If at least one value does not satisfy the predicate, at the end of the process:
#
# 1. Lists such items, in arrival order
#
# 2. Fails via the assertion-dedicated `fail` function
#
fn enforce-predicate { |assertion-reference entry-predicate failure-entries-description|
  var failure-entries = [(
    each { |entry|
      if (not ($entry-predicate $entry)) {
        put $entry
      }
    }
  )]

  if (seq:is-non-empty $failure-entries) {
    output:highlight-wrong $failure-entries-description $failure-entries

    fail $assertion-reference
  }
}