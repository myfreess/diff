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
  let arr = []
  for i = 0; i < str.length(); i = i + 1 {
    let ch = str[i]
    if ch == '\n' {
      let text = buf.to_string()
      buf.reset()
      line_number = line_number + 1
      arr.push(Line::new(line_number, text))
    } else {
      buf.write_char(ch)
    }
  } else {
    // 可能文本不以换行符为结尾
    let text = buf.to_string()
    if text != "" {
      line_number = line_number + 1
      arr.push(Line::new(line_number, text))
    }
    arr
  }
}