struct Box {
  left : Int
  right : Int
  top : Int
  bottom : Int
}

struct Snake {
  start : (Int, Int)
  end : (Int, Int)
}

fn width(self : Box) -> Int {
  self.right - self.left
}

fn height(self : Box) -> Int {
  self.bottom - self.top
}

fn size(self : Box) -> Int {
  self.width() + self.height()
}

fn delta(self : Box) -> Int {
  self.width() - self.height()
}



fn midpoint(self : Box) -> Snake? {
  None
}