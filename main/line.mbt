struct Line {
  number : Int
  text : String // 不包含换行
} derive(Debug, Show)

fn Line::new(number : Int, text : String) -> Line {
  Line::{ number : number, text : text }
}

fn lines(str : String) -> Array[Line] {
  let mut line_number = 0
  let buf = Buffer::make(50)
  let mut lst = List::Nil
  for i = 0; i < str.length(); i = i + 1 {
    let ch = str[i]
    if ch == '\n' {
      let text = buf.to_string()
      buf.reset()
      line_number = line_number + 1
      lst = List::[Line::new(line_number, text)] + lst
    } else {
      buf.write_char(ch)
    }
  } else {
    let idx = line_number - 1
    let arr = Array::make(line_number, Line::new(-1, ""))
    loop lst, idx {
      Nil, _ => arr
      Cons(line, rest), idx => {
        arr[idx] = line
        continue rest, idx - 1
      }
    }
  }
}