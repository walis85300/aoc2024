import gleam/string
import simplifile.{read}

pub fn read_file(filename: String) {
  let assert Ok(records) = read(from: filename)
  records |> string.trim_end
}
