struct Box {
  left : Int
  right : Int
  top : Int
  bottom : Int
} derive(Debug, Show)

struct Snake {
  start : (Int, Int)
  end : (Int, Int)
} derive(Debug, Show)

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

fn is_odd(n : Int) -> Bool {
  n.land(1) == 1
}

fn is_even(n : Int) -> Bool {
  n.land(1) == 0
}

fn forward(self : Box, vf : BPArray[Int], vb : BPArray[Int], d : Int, a : Array[Line], b : Array[Line]) -> Snake? {
  for k = d; k >= -d; k = k - 2 {
    let c = k - self.delta()
    let mut x = 0
    let mut px = 0
    if k == -d || (k != d && vf[k - 1] < vf[k + 1]) {
      x = vf[k + 1]
      px = x
    } else {
      px = vf[k - 1]
      x = px + 1
    }
    let mut y = self.top + (x - self.left) - k
    let py = if (d == 0 || x != px) { y } else { y - 1 }
    while x < self.right && y < self.bottom && a[x].text == b[y].text {
      x = x + 1
      y = y + 1
    }
    vf[k] = x
    if is_odd(self.delta()) && (c >= -(d - 1) && c <= d - 1) && y >= vb[c] {
      return Some(Snake::{ start : (px, py), end : (x, y) })
    }
  }
  return None
}

fn backward(self : Box, vf : BPArray[Int], vb : BPArray[Int], d : Int, a : Array[Line], b : Array[Line]) -> Snake? {
  for c = d; c >= -d; c = c - 2 {
    let k = c + self.delta()
    let mut y = 0
    let mut py = 0
    if c == -d || (c != d && vb[c - 1] > vb[c + 1]) {
      y = vb[c + 1]
      py = y
    } else {
      py = vb[c - 1]
      y = py - 1
    }
    let mut x = self.left + (y - self.top) + k
    let px = if (d == 0 || y != py) { x } else { x + 1 }
    while x > self.left && y > self.top && a[x - 1].text == b[y - 1].text {
      x = x - 1
      y = y - 1
    }
    vb[c] = y
    if is_even(self.delta()) && (k >= -d && k <= d) && x <= vf[k] {
      return Some(Snake::{ start : (x, y), end : (px, py) })
    }
  }
  return None
}

fn midpoint(self : Box, a : Array[Line], b : Array[Line]) -> Snake? {
  if self.size() == 0 {
    return None
  }
  let max = {
    let half = self.size() / 2
    if half * 2 < self.size() {
      half + 1
    } else {
      half
    }
  }
  let vf = BPArray::make(2 * max + 1, 0)
  vf[1] = self.left
  let vb = BPArray::make(2 * max + 1, 0)
  vb[1] = self.bottom
  for d = 0; d < max + 1; d = d + 1 {
    match forward(self, vf, vb, d, a, b) {
      None => 
      match backward(self, vf, vb, d, a, b) {
        None => continue
        res => return res
      }
      res => return res
    }
  } else {
    None
  }
}

fn find_path(box : Box, a : Array[Line], b : Array[Line]) -> Option[Iter[(Int, Int)]] {
  let snake = midpoint(box, a, b)?
  let start = snake.start
  let end = snake.end
  let headbox = Box::{ left : box.left, top : box.top, right : start.0, bottom : start.1 }
  let tailbox = Box::{ left : end.0, top : end.1, right : box.right, bottom : box.bottom }
  // println("snake = \(snake)")
  // println("headbox = \(headbox)")
  // println("tailbox = \(tailbox)")
  let head = find_path(headbox, a, b).or(Iter::singleton(start))
  let tail = find_path(tailbox, a, b).or(Iter::singleton(end))
  Some(head.concat(tail))
}

fn linear_diff(a : Array[Line], b : Array[Line]) -> Option[Array[Edit]] {
  let initial_box = Box::{ left : 0, top : 0, right : a.length(), bottom : b.length() }
  let path = find_path(initial_box, a, b)?
  // path length >= 2
  let xy = path.take(1).collect()[0] // (0, 0)
  let mut x1 = xy.0
  let mut y1 = xy.1
  let edits = Array::new(capacity = a.length() + b.length())
  path.drop(1).each(fn (xy){
    let x2 = xy.0
    let y2 = xy.1
    while x1 < x2 && y1 < y2 && a[x1].text == b[y1].text {
      edits.push(Equal(old = a[x1], new = b[y1]))
      x1 = x1 + 1
      y1 = y1 + 1
    }
    if x2 - x1 < y2 - y1 {
      edits.push(Insert(new = b[y1]))
      y1 += 1
    }
    if x2 - x1 > y2 - y1 {
      edits.push(Delete(old = a[x1]))
      x1 += 1
    }
    while x1 < x2 && y1 < y2 && a[x1].text == b[y1].text {
      edits.push(Equal(old = a[x1], new = b[y1]))
      x1 = x1 + 1
      y1 = y1 + 1
    }
    x1 = x2
    y1 = y2
  })
  return Some(edits)
}