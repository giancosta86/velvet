use ./assertion
use ./exception

echo ⚛ Exception detection

{
  echo ▶ On number

  exception:is-exception 90 |
    not (all) |
    assertion:assert (all)
}

{
  echo ▶ On fail

  exception:is-exception ?(fail DODO) |
    assertion:assert (all)
}

{
  echo ▶ On return

  exception:is-exception ?(return) |
    assertion:assert (all)
}

echo ⚛ ✅
echo

echo ⚛ Failure message retrieval

{
  echo ▶ On number

  exception:get-fail-message 90 |
    eq (all) $nil |
    assertion:assert (all)
}

{
  echo ▶ On fail

  exception:get-fail-message ?(fail DODO) |
    eq (all) DODO |
    assertion:assert (all)
}

{
  echo ▶ On return

  exception:get-fail-message ?(return) |
    eq (all) $nil |
    assertion:assert (all)
}

echo ⚛ ✅
echo

echo ⚛ Return detection

{
  echo ▶ On number

  exception:is-return 90 |
    not (all) |
    assertion:assert (all)
}

{
  echo ▶ On fail

  exception:is-return ?(fail DODO) |
    not (all) |
    assertion:assert (all)
}

{
  echo ▶ On return

  exception:is-return ?(return) |
    assertion:assert (all)
}

echo ⚛ ✅
echo
