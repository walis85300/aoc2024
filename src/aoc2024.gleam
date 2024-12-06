import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

pub fn main() {
  let assert Ok(records) = read(from: "./aoc2024_5.txt")

  let lines =
    records
    |> string.trim_end
    |> string.split(on: "\n\n")
    |> list.map(fn(x) { string.split(x, on: "\n") })

  let #(rules, printing) = case lines {
    [a, b] -> #(a, b)
    _ -> panic
  }

  let prev_numbers =
    rules
    |> list.map(fn(x) {
      let a = string.split(x, on: "|")

      case a {
        [number, _] -> number
        _ -> panic
      }
    })

  let post_numbers =
    rules
    |> list.map(fn(x) {
      let a = string.split(x, on: "|")

      case a {
        [_, number] -> number
        _ -> panic
      }
    })

  let post_numbers_dict =
    prev_numbers
    |> list.map(fn(x) {
      let after_numbers =
        rules
        |> list.filter(fn(y) {
          let a = string.split(y, on: "|")
          case a {
            [n, _] if n == x -> True
            _ -> False
          }
        })
        |> list.map(fn(y) {
          let a = string.split(y, on: "|")
          case a {
            [_, after_n] -> after_n
            _ -> panic
          }
        })
      #(x, after_numbers)
    })
    |> dict.from_list

  let prev_numbers_dict =
    post_numbers
    |> list.map(fn(x) {
      let prev_numbers =
        rules
        |> list.filter(fn(y) {
          let a = string.split(y, on: "|")
          case a {
            [_, n] if n == x -> True
            _ -> False
          }
        })
        |> list.map(fn(y) {
          let a = string.split(y, on: "|")
          case a {
            [prev_n, _] -> prev_n
            _ -> panic
          }
        })
      #(x, prev_numbers)
    })
    |> dict.from_list

  printing
  |> list.filter(fn(x) {
    let p =
      x
      |> string.split(on: ",")

    p
    |> list.index_map(fn(number, index) {
      let pn = list.take(p, index)
      let nn = list.drop(p, index + 1)

      let valid_next_number = case post_numbers_dict |> dict.get(number) {
        Ok(u) -> u
        _ -> []
      }

      let valid_prev_numbers = case prev_numbers_dict |> dict.get(number) {
        Ok(u) -> u
        _ -> []
      }

      let contains_invalid_previous =
        list.any(valid_next_number, fn(vnn) { list.contains(pn, vnn) })

      let contains_invalid_next =
        list.any(valid_prev_numbers, fn(vpn) { list.contains(nn, vpn) })

      case contains_invalid_previous, contains_invalid_next {
        False, False -> True
        _, _ -> False
      }
    })
    |> list.all(fn(k) { k })
  })
  |> list.map(fn(e) {
    let n = e |> string.split(on: ",")
    let len = list.length(n)
    let middle_i = len / 2

    let assert Ok(middle) =
      n
      |> list.drop(middle_i)
      |> list.first
    case int.parse(middle) {
      Ok(n) -> n
      _ -> 0
    }
  })
  |> list.fold(0, fn(a, acc) { a + acc })
  |> io.debug
}
