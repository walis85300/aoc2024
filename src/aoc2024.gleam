import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

fn check_line(head: Int, line: List(Int), initial_operation: String) {
  case line {
    [h, ..b] -> {
      let operation = case h {
        h if h < head -> "inc"
        h if h > head -> "dec"
        _ -> "equ"
      }

      let initial_operation = case initial_operation {
        "default" -> operation
        _ -> initial_operation
      }

      let difference = int.absolute_value(head - h)

      case operation, difference {
        _, diff if diff > 3 -> {
          False
        }
        op, _ if op == "equ" || op != initial_operation -> {
          False
        }
        _, _ -> {
          check_line(h, b, operation)
        }
      }
    }
    [] -> True
  }
}

pub fn remove_at(list: List(Int), index: Int) -> List(Int) {
  case list, index {
    [], _ -> []
    [_, ..xs], 0 -> xs
    [x, ..xs], i -> [x, ..remove_at(xs, i - 1)]
  }
}

pub fn try_removing_one(line: List(Int)) -> Bool {
  let len = list.length(line)
  list.range(0, len)
  |> list.any(fn(i) {
    let new_line = remove_at(line, i)
    case new_line {
      [h, ..r] -> check_line(h, r, "default")
      [] -> False
    }
  })
}

pub fn main() {
  let assert Ok(records) = read(from: "./aoc2024_2.txt")

  string.trim_end(records)
  |> string.split(on: "\n")
  |> list.map(fn(x) {
    string.split(x, on: " ")
    |> list.map(fn(y) {
      case int.parse(y) {
        Ok(r) -> r
        _ -> panic
      }
    })
  })
  |> list.map(fn(line) {
    let result = case line {
      [h, ..r] -> check_line(h, r, "default")
      [] -> False
    }
    case result {
      False -> try_removing_one(line)
      _ -> result
    }
  })
  |> list.count(fn(x) { x })
  |> io.debug
}
