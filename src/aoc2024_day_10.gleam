import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import simplifile.{read}

const move_up = #(0, -1)

const move_down = #(0, 1)

const move_right = #(1, 0)

const move_left = #(-1, 0)

const path = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]

type Position =
  #(Int, Int)

type DictMap =
  Dict(Position, Int)

fn move_point(p1: Position, p2: Position) -> Position {
  let #(x1, y1) = p1
  let #(x2, y2) = p2
  #(x1 + x2, y1 + y2)
}

fn move(map, n, r, position, initial_position) {
  [
    move_in_map(map, n, r, move_point(position, move_up), initial_position),
    move_in_map(map, n, r, move_point(position, move_down), initial_position),
    move_in_map(map, n, r, move_point(position, move_right), initial_position),
    move_in_map(map, n, r, move_point(position, move_left), initial_position),
  ]
}

fn move_in_map(
  map: DictMap,
  num: Int,
  path: List(Int),
  position: Position,
  initial_position: Position,
) {
  let element = map |> dict.get(position)

  case element {
    Ok(e) -> {
      case e, path {
        e, [] if e == 0 -> [#(initial_position, position)]
        e, _ if e == num -> {
          case path {
            [n, ..r] -> {
              move(map, n, r, position, initial_position)
              |> list.flatten
            }
            _ -> []
          }
        }
        _, _ -> []
      }
    }
    _ -> []
  }
}

pub fn main() {
  let assert Ok(records) = read(from: "./aoc2024_10.txt")

  let map =
    records
    |> string.trim_end
    |> string.split(on: "\n")
    |> list.index_map(fn(y, index_y) {
      string.split(y, on: "")
      |> list.index_map(fn(x, index_x) {
        let assert Ok(x) = x |> int.parse
        #(#(index_x, index_y), x)
      })
    })
    |> list.flatten

  let dict_map: DictMap = map |> dict.from_list

  let nines =
    map
    |> list.filter(fn(x) {
      case x {
        #(#(_, _), a) if a == 9 -> True
        _ -> False
      }
    })
    |> list.map(fn(x) {
      let #(a, _) = x
      a
    })

  // first part
  nines
  |> list.map(fn(p) {
    case path {
      [h, ..r] -> move_in_map(dict_map, h, r, p, p)
      _ -> []
    }
    |> list.map(fn(x) {
      let #(_, b) = x
      b
    })
    // get all the destinations
    |> set.from_list
    |> set.to_list
    // ensure unique destinations
  })
  |> list.fold(0, fn(acc, a) { { a |> list.length } + acc })
  |> io.debug

  // second part
  nines
  |> list.map(fn(p) {
    case path {
      [h, ..r] -> move_in_map(dict_map, h, r, p, p)
      _ -> []
    }
    |> list.group(fn(i) { i })
    |> dict.to_list
    |> list.map(fn(a) {
      let #(_, b) = a
      b |> list.length
    })
  })
  |> list.flatten
  |> list.fold(0, fn(a, acc) { a + acc })
  |> io.debug
}
