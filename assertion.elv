use builtin
use github.com/giancosta86/ethereal/v1/fs
use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/seq
use ./output

var failure-prefix = 'Assertion failed: '

#
# Given an assertion reference - an assertion name or the output of the `src` function
# called from within the script of an assertion or the related test file - returns the
# assertion name, such as `should-be`.
#
fn get-name { |@arguments|
  var assertion-reference = (lang:get-single-input $arguments)

  if (eq (kind-of $assertion-reference) map) {
    put $assertion-reference[name] |
      fs:get-script-subject
  } else {
    put $assertion-reference
  }
}

#
# Creates an assertion-specific failure message having a recognizable prefix.
#
# This function is designed for fairly specific uses all over the codebase:
# instead of using it directly, you should call the assertion-specific `fail` function instead.
#
fn format-failure { |@arguments|
  var assertion-name = (get-name $@arguments)

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
    output:display-wrong $failure-entries-description $failure-entries

    fail $assertion-reference
  }
}

#
# Emits the assertion subject, passed via pipe - failing if it's not a string.
#
fn get-string-subject {
  var subject = (one)

  if (not (eq (kind-of $subject) string)) {
    builtin:fail 'The subject must be a string'
  }

  put $subject
}

#
# Enforces that the given assertion argument is a string - failing otherwise.
#
fn enforce-string-argument { |argument|
  if (not (eq (kind-of $argument) string)) {
    builtin:fail 'The assertion argument must be a string'
  }
}