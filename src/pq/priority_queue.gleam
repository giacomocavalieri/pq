import gleam/order.{type Order, Eq, Gt, Lt}

pub opaque type PriorityQueue(a) {
  PriorityQueue(forest: List(Tree(a)), compare: fn(a, a) -> Order)
}

pub fn new(compare: fn(a, a) -> Order) -> PriorityQueue(a) {
  PriorityQueue([], compare)
}

pub fn is_empty(queue: PriorityQueue(a)) -> Bool {
  case queue {
    PriorityQueue(forest: [], ..) -> True
    _ -> False
  }
}

pub fn insert(into queue: PriorityQueue(a), item item: a) -> PriorityQueue(a) {
  add_to_forest(Tree(0, item, []), queue.forest, queue.compare)
  |> PriorityQueue(compare: queue.compare)
}

pub fn minimum(queue: PriorityQueue(a)) -> Result(a, Nil) {
  case queue {
    PriorityQueue(forest: [], ..) -> Error(Nil)
    PriorityQueue(forest: [tree, ..rest], compare: compare) ->
      Ok(do_minimum(tree.item, rest, compare))
  }
}

fn do_minimum(
  current_min: a,
  forest: List(Tree(a)),
  compare: fn(a, a) -> Order,
) -> a {
  case forest {
    [] -> current_min
    [tree, ..rest] ->
      case compare(current_min, tree.item) {
        Lt | Eq -> do_minimum(current_min, rest, compare)
        Gt -> do_minimum(tree.item, rest, compare)
      }
  }
}

pub fn delete_minimum(queue: PriorityQueue(a)) -> PriorityQueue(a) {
  todo
}

// BINOMIAL TREES --------------------------------------------------------------

type Tree(a) {
  Tree(rank: Int, item: a, children: List(Tree(a)))
}

fn link_trees(
  one: Tree(a),
  other: Tree(a),
  compare: fn(a, a) -> Order,
) -> Tree(a) {
  case compare(one.item, other.item) {
    Lt | Eq -> Tree(one.rank + 1, one.item, [other, ..one.children])
    Gt -> Tree(other.rank + 1, other.item, [one, ..other.children])
  }
}

fn add_to_forest(
  one: Tree(a),
  forest: List(Tree(a)),
  compare: fn(a, a) -> Order,
) -> List(Tree(a)) {
  case forest {
    [] -> [one]
    [other, ..rest] ->
      case one.rank < other.rank {
        True -> [one, other, ..rest]
        False ->
          link_trees(one, other, compare)
          |> add_to_forest(forest, compare)
      }
  }
}
