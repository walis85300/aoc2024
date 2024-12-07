import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

fn mult(a: Int, b: Int) -> Int {
  a * b
}

fn summ(a: Int, b: Int) -> Int {
  a + b
}

fn concat(a: Int, b: Int) -> Int {
  let a = a |> int.to_string
  let b = b |> int.to_string
  let c = a <> b
  let assert Ok(c) = c |> int.parse
  c
}

fn calculate(result: Int, numbers: List(Int), carry: Int) {
  case numbers, carry {
    [], carry if carry == result -> True
    _, carry if carry > result -> False
    [n, ..r], carry -> {
      let next_result = mult(carry, n)
      case calculate(result, r, next_result) {
        True -> True
        False -> {
          let next_result = summ(carry, n)
          case calculate(result, r, next_result) {
            True -> True
            False -> {
              let next_result = concat(carry, n)
              calculate(result, r, next_result)
            }
          }
        }
      }
    }
    _, _ -> False
  }
}

pub fn main() {
  let assert Ok(records) = read(from: "./aoc2024_7.txt")

  records
  |> string.trim_end
  |> string.split(on: "\n")
  |> list.map(fn(x) {
    case x |> string.split(":") {
      [r, n] -> {
        let n =
          n
          |> string.trim
          |> string.split(" ")
          |> list.map(fn(i) {
            let assert Ok(i) = int.parse(i)
            i
          })
        let assert Ok(r) = int.parse(r)
        #(r, n)
      }
      _ -> panic
    }
  })
  |> list.filter(fn(x) {
    case x {
      #(r, [n, ..l]) -> calculate(r, l, n)
      _ -> False
    }
  })
  |> list.fold(0, fn(a, acc) {
    case acc {
      #(n, _) -> a + n
    }
  })
  |> io.debug
}
