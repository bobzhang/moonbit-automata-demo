///|
test (it : @test.Test) {
  @lib.reset_dfa_id()
  let a = @lib.DFAState::new()
  let b = @lib.DFAState::new()
  let c = @lib.DFAState::new(final=true)

  a.connect_to(b, edge='c')
  b.connect_to(c, edge='d')
  // The fixture accepts exactly "cd": its second edge starts at b, not a.
  for input in ["", "c", "d", "cc", "cdd"] {
    assert_false(dfa_accepts(a, input))
  }
  assert_true(dfa_accepts(a, "cd"))
  it.write(a.to_mermaid())
  it.snapshot(filename="dfa_test.md")
}

///|
fn dfa_accepts(start : @lib.DFAState, input : String) -> Bool {
  let mut state = start
  for char in input {
    match state.trainsitions.get(char) {
      Some(next) => state = next
      None => return false
    }
  }
  state.final
}
