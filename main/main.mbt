


fn main {
  let a = lines("A\nB\nC\nA\nB\nB\nA")
  let b = lines("C\nB\nA\nB\nA\nC")
  let foo = diff(a, b)
  print_diff(foo)
}
