
type BPArray[T] Array[T] // BiPolar Array 
  

fn BPArray::make[T](capacity : Int, default : T) -> BPArray[T] {
  let arr = Array::make(capacity, default)
  BPArray(arr)
}

fn copy(self : BPArray[Int]) -> BPArray[Int] {
  let BPArray(arr) = self
  let newarr = Array::make(arr.length(), 0)
  for i = 0; i < arr.length(); i = i + 1 {
    newarr[i] = arr[i]
  } else {
    BPArray(newarr)
  }
}

fn op_get[T](self : BPArray[T], idx : Int) -> T {
  let BPArray(arr) = self
  if idx < 0 {
    arr[arr.length() + idx]
  } else {
    arr[idx]
  }
}

fn op_set[T](self : BPArray[T], idx : Int, elem : T) -> Unit {
  let BPArray(arr) = self
  if idx < 0 {
    arr[arr.length() + idx] = elem
  } else {
    arr[idx] = elem
  }
}


fn shortst_edit(a : Array[Line], b : Array[Line]) -> Array[(BPArray[Int], Int)] {
  let n = a.length()
  let m = b.length()
  let max = n + m
  let v = BPArray::make(2 * max + 1, 0)
  let trace = []
  fn push(v : BPArray[Int], d : Int) -> Unit {
    trace.push((v, d))
  }
  // v[1] = 0
  for d = 0; d < max + 1; d = d + 1 {
    push(v.copy(), d)
    for k = -d; k < d + 1; k = k + 2 {
      let mut x = 0
      let mut y = 0
      // if d == 0 {
      //   x = 0
      // }
      if k == -d || (k != d && v[k - 1] < v[k + 1]) {
        x = v[k + 1]
      } else {
        x = v[k - 1] + 1
      }
      y = x - k
      while x < n && y < m && a[x].text == b[y].text {
        x = x + 1
        y = y + 1
      }
      
      v[k] = x
      if x >= n && y >= m {
        return trace
      }
    }
  } else {
    abort("impossible")
  }
}

fn backtrack(a : Array[Line], b : Array[Line], trace : Array[(BPArray[Int], Int)]) -> Array[Edit] {
  let mut x = a.length()
  let mut y = b.length()
  let edits = []
  fn push(edit : Edit) -> Unit {
    edits.push(edit)
  }
  for i = trace.length() - 1; i >= 0; i = i - 1 {
    let (v, d) = trace[i]
    let k = x - y
    let prev_k = if k == -d || (k != d && v[k - 1] < v[k + 1]) {
      k + 1
    } else {
      k - 1
    }
    let prev_x = v[prev_k]
    let prev_y = prev_x - prev_k
    while x > prev_x && y > prev_y {
      x = x - 1
      y = y - 1
      push(Equal(old = a[x], new = b[y]))
    }
    if d > 0 {
      if x == prev_x {
        push(Insert(new = b[prev_y]))
      } else if y == prev_y {
        push(Delete(old = a[prev_x]))
      }
      x = prev_x
      y = prev_y
    }
  }
  return edits
}

fn diff(a : Array[Line], b : Array[Line]) -> Array[Edit] {
  let trace = shortst_edit(a, b)
  backtrack(a, b, trace)
}

fn print_diff(diff : Array[Edit]) -> Unit {
  for i = diff.length() - 1; i >= 0; i = i - 1 {
    diff[i] 
    |> print_edit 
    |> println
  }
}