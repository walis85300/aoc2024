import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

type Point =
  #(Int, Int)

type Element =
  #(Point, String)

type Map =
  List(Element)

type DictMap =
  Dict(Point, String)

const blocked_cell = "#"

const used_cell = "X"

const move_up = #(0, -1)

const move_down = #(0, 1)

const move_right = #(1, 0)

const move_left = #(-1, 0)

const up = "^"

const down = "v"

const left = ">"

const right = "<"

fn move_point(p1: Point, p2: Point) -> Point {
  let #(x1, y1) = p1
  let #(x2, y2) = p2
  #(x1 + x2, y1 + y2)
}

fn rotate(p: Point) -> Point {
  case p {
    x if x == move_up -> move_right
    x if x == move_right -> move_down
    x if x == move_down -> move_left
    _ -> move_up
  }
}

fn find_initial_position(list_positions: Map) -> Element {
  case list_positions {
    [#(a, b), ..] if b == up || b == down || b == left || b == right -> #(a, b)
    [_, ..l] -> find_initial_position(l)
    _ -> panic
  }
}

fn move_in_map(point: Point, map: DictMap, direction: Point) -> DictMap {
  let map = map |> dict.insert(point, used_cell)

  let next_poisition = move_point(point, direction)
  let next_element = map |> dict.get(next_poisition)

  case next_element {
    Ok(e) -> {
      case e {
        e if e == blocked_cell -> {
          let new_direction = rotate(direction)
          move_in_map(point, map, new_direction)
        }
        _ -> {
          move_in_map(next_poisition, map, direction)
        }
      }
    }
    _ -> map
  }
}

pub fn main() {
  let assert Ok(records) = read(from: "./aoc2024_6.txt")

  let map: Map =
    records
    |> string.trim_end
    |> string.split(on: "\n")
    |> list.index_map(fn(y, index_y) {
      string.split(y, on: "")
      |> list.index_map(fn(x, index_x) { #(#(index_x, index_y), x) })
    })
    |> list.flat_map(fn(x) { x })

  let dict_map: DictMap = map |> dict.from_list

  let #(initial_position, initial_sign): Element =
    find_initial_position(map) |> io.debug

  let initial_direction = case initial_sign {
    e if e == up -> move_up
    e if e == down -> move_down
    e if e == left -> move_left
    _ -> move_right
  }

  move_in_map(initial_position, dict_map, initial_direction)
  |> dict.to_list
  |> list.count(fn(x) {
    case x {
      #(_, s) if s == used_cell -> True
      _ -> False
    }
  })
  |> io.debug
}
