>> 'In gamma' {
  >> 'should pass' {
    echo Gamma 3
  }
}

>> 'In beta' {
  >> 'is duplicated in third source file' {
    echo Beta 4
  }
}

>> 'In alpha' {
  >> 'should work too' {
    echo Alpha 5
    put 90
  }

  >> 'In sub-level' {
    >> 'should fail' {
      echo Cip
      echo Ciop >&2

      fail DODO
    }
  }
}