enum Edit {
  Insert(~new : Line)
  Delete(~old : Line)
  Equal(~old : Line, ~new : Line) // old, new
} derive(Debug, Show)


let line_width = 4

fn pad_right(s : String, width : Int) -> String {
  String::make(width - s.length(), ' ') + s
}

fn print_edit(edit : Edit) -> String {
  match edit {
    Insert(_) as edit => {
      let tag = "+"
      let old_line = pad_right("", line_width)
      let new_line = pad_right(edit.new.number.to_string(), line_width)
      let text = edit.new.text
      "\(tag) \(old_line) \(new_line)    \(text)"
    }
    Delete(_) as edit => {
      let tag = "-"
      let old_line = pad_right(edit.old.number.to_string(), line_width)
      let new_line = pad_right("", line_width)
      let text = edit.old.text
      "\(tag) \(old_line) \(new_line)    \(text)"
    }
    Equal(_) as edit => {
      let tag = " "
      let old_line = pad_right(edit.old.number.to_string(), line_width)
      let new_line = pad_right(edit.new.number.to_string(), line_width)
      let text = edit.old.text
      "\(tag) \(old_line) \(new_line)    \(text)"
    }
  }
}

fn print_diff(diff : Array[Edit]) -> Unit {
  for i = 0; i < diff.length(); i = i + 1 {
    diff[i] 
    |> print_edit 
    |> println
  }
}

