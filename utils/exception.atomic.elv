use ./assertion
use ./exception

echo ⚛ Failure message retrieval

{
  echo ▶ On empty map

  exception:get-fail-message [&] |
    eq (all) $nil |
    assertion:assert (all)
}

{
  echo ▶ On actual failure

  exception:get-fail-message ?(fail DODO) |
    ==s (all) DODO |
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