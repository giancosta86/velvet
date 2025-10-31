>> 'In beta' {
  >> 'has duplicate in third source file' {
    echo Beta 2
  }
}

>> 'In alpha' {
  >> 'In sub-level' {
    >> 'In sub-sub-level' {
      >> 'should be ok' {
        echo Alpha X >&2
      }
    }
  }
}