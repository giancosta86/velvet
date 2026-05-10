use str
use github.com/giancosta86/ethereal/v1/map
use ./ethereal

>> 'Loading Ethereal namespaces' {
  >> 'should work' {
    map:iterate $ethereal:namespaces { |namespace-name namespace|
      str:has-suffix $namespace-name ':' |
        should-be $true

      kind-of $namespace |
        should-be ns
    }
  }
}