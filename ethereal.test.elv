use str
use github.com/giancosta86/ethereal/v1/map
use ./ethereal

>> 'Loading Ethereal namespaces' {
  >> 'should work' {
    map:entries $ethereal:namespaces | each { |entry|
      var namespace-name namespace = (all $entry)

      str:has-suffix $namespace-name ':' |
        should-be $true

      kind-of $namespace |
        should-be ns
    }
  }
}