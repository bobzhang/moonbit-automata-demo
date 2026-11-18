///|
#derive(Eq, Compare, Default, ToJson)
struct Id {
  id : Int32
  description : String?
}

///|
#derive(Default, ToJson)
pub enum Edge {
  Epsilon
  Char(Char)
}

///|
impl Show for Edge with fn output(self, logger) {
  match self {
    Edge::Epsilon => logger.write_string("ε")
    Edge::Char(c) => logger.write_object(Repr(c))
  }
}

///|
pub fn Edge::to_string(self : Edge) -> String {
  Show::to_string(self)
}

///|
impl Show for Id with fn output(self, logger) {
  logger.write_object(self.id)
  match self.description {
    Some(desc) => logger.write_string(": " + desc)
    None => ()
  }
}

///|
pub fn Id::to_string(self : Id) -> String {
  Show::to_string(self)
}

///|
let id : Ref[Int32] = { val: 0, }

///|
pub fn reset_id() -> Unit {
  id.val = 0
}

///|
fn gen_id(name? : String) -> Id {
  id.val += 1
  { id: id.val, description: name, }
}

///|
pub struct State {
  id : Id
  transitions : Array[(Edge, State)]
}

///|
pub impl Show for State with fn output(self, logger) {
  logger.write_object(self.id)
}

///|
pub impl ToJson for State with fn to_json(self) {
  {
    "id": ToJson::to_json(self.id),
    "transitions": ToJson::to_json(self.transitions.length()),
  }
}

///|
impl Hash for State with fn hash_combine(self, hasher) {
  hasher.combine(self.id.id)
}

// TODO: in general, impl woud be pub??

///|
pub impl Eq for State with fn equal(self, other) {
  self.id == other.id
}

///|
pub impl Compare for State with fn compare(self, other) {
  Compare::compare(self.id, other.id)
}

///|
fn State::compare(self : State, other : State) -> Int32 {
  Compare::compare(self, other)
}

///|
fn State::equal(self : State, other : State) -> Bool {
  Eq::equal(self, other)
}

///|
pub fn State::closure(self : State) -> Set[State] {
  let result = Set::from_array([self])
  for curr_states = Set::from_array([self]) {
    let fresh_added = Set::new()
    for st in curr_states {
      for trans in st.transitions {
        match trans.0 {
          Epsilon =>
            if !result.contains(trans.1) {
              fresh_added.add(trans.1)
              result.add(trans.1)
            }
          Char(_) => ()
        }
      }
    }
    if fresh_added.is_empty() {
      break
    } else {
      continue fresh_added
    }
  }
  result
}

//TODO how to  // { "path": "immut/sorted_set", "alias": "immset"}

///|
pub fn closure_of_set(
  states : @sorted_set.SortedSet[State],
) -> @sorted_set.SortedSet[State] {
  let mut result = states
  for curr_states = states {
    let mut fresh_added = @sorted_set.new()
    for st in curr_states {
      for trans in st.transitions {
        match trans.0 {
          Epsilon =>
            if !result.contains(trans.1) {
              fresh_added = fresh_added.add(trans.1)
              result = result.add(trans.1)
              // result.insert(trans.1)
            }
          Char(_) => ()
        }
      }
    }
    if fresh_added.is_empty() {
      break
    } else {
      continue fresh_added
    }
  }
  result
}

///|
/// edges of closure modulo epsilon
pub fn edges_of_closure(
  states : @sorted_set.SortedSet[State],
) -> @sorted_set.SortedSet[Char] {
  let mut edges = @sorted_set.new()
  for state in states {
    for trans in state.transitions {
      match trans.0 {
        Epsilon => ()
        Char(c) => edges = edges.add(c)
      }
    }
  }
  edges
}

///|
pub fn step_of_closure(
  states : @sorted_set.SortedSet[State],
  edge : Char,
) -> @sorted_set.SortedSet[State] {
  let mut result = @sorted_set.new()
  for state in states {
    for trans in state.transitions {
      match trans.0 {
        Epsilon => ()
        Char(c) => if c == edge { result = result.add(trans.1) }
      }
    }
  }
  closure_of_set(result)
}

///|
pub struct NFA {
  start : State
  states : Array[State]
  final : State
}

///|
pub fn NFA::new(start~ : State, states~ : Array[State], final~ : State) -> NFA {
  NFA::{ start, states, final, }
}

///|
pub fn State::new(name? : String) -> State {
  let id = gen_id(name?)
  State::{ id, transitions: [], }
}

///|
pub fn State::connect_to(self : State, other : State, edge? : Char) -> Unit {
  let edge = match edge {
    Some(c) => Edge::Char(c)
    None => Edge::Epsilon
  }
  self.transitions.push((edge, other))
}

///|
pub fn NFA::to_mermaid(self : NFA) -> String {
  let sb = StringBuilder::StringBuilder()
  let indent = "  "
  for state in self.states {
    if state.id.description != None {
      sb.write_string(indent)
      sb.write_object(state.id)
      sb.write_string("\n")
    }
    // sb.write_string(indent)
    // sb.write_object(state.id)
    // sb.write_string("\n")
  }
  for state in self.states {
    for trans in state.transitions {
      sb.write_string(indent)
      sb.write_object(state.id.id) // only id needed
      sb.write_string(" --> ")
      sb.write_object(trans.1.id.id)
      sb.write_string(" : ")
      sb.write_object(trans.0)
      sb.write_string("\n")
    }
  }
  // TODO allow " in $|
  let content = sb.to_string().trim_end(chars="\n")
  (
    #|```mermaid
    #|  stateDiagram-v2
    $|\{content}
    #|```
  )
}
