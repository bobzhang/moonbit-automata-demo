///|
test {
  debug_inspect(
    (Ok(@lib.parse("abcd")) catch { error => Err(error) }).unwrap(),
    content="Seq(Seq(Seq(Seq(Empty, Char('a')), Char('b')), Char('c')), Char('d'))",
  )
  debug_inspect(
    (Ok(@lib.parse(["star", "a"])) catch { error => Err(error) }).unwrap(),
    content="Star(Seq(Empty, Char('a')))",
  )

  //a+b+
  debug_inspect(
    Ok(@lib.parse(["seq", ["plus", "a"], ["plus", "b"]])) catch {
      error => Err(error)
    },
    content="Ok(Seq(Plus(Seq(Empty, Char('a'))), Plus(Seq(Empty, Char('b')))))",
  )
}
