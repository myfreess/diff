


fn main {
  let a = lines("A\nB\nC\nA\nB\nB\nA")
  let b = lines("C\nB\nA\nB\nA\nC")
  let r = shortst_edit(a, b)
  println(r)
}
