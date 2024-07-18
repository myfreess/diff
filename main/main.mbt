



let before =
  #|void Chunk_copy(Chunk *src, size_t src_start, Chunk *dst, size_t dst_start, size_t n)
  #|{
  #|    if (!Chunk_bounds_check(src, src_start, n)) return;
  #|    if (!Chunk_bounds_check(dst, dst_start, n)) return;
  #|
  #|    memcpy(dst->data + dst_start, src->data + src_start, n);
  #|}
  #|
  #|int Chunk_bounds_check(Chunk *chunk, size_t start, size_t n)
  #|{
  #|    if (chunk == NULL) return 0;
  #|
  #|    return start <= chunk->length && n <= chunk->length - start;
  #|}

let after =
  #|int Chunk_bounds_check(Chunk *chunk, size_t start, size_t n)
  #|{
  #|    if (chunk == NULL) return 0;
  #|
  #|    return start <= chunk->length && n <= chunk->length - start;
  #|}
  #|
  #|void Chunk_copy(Chunk *src, size_t src_start, Chunk *dst, size_t dst_start, size_t n)
  #|{
  #|    if (!Chunk_bounds_check(src, src_start, n)) return;
  #|    if (!Chunk_bounds_check(dst, dst_start, n)) return;
  #|
  #|    memcpy(dst->data + dst_start, src->data + src_start, n);
  #|}

fn path1() -> Unit {
  let a = lines(before)
  let b = lines(after)
  let initial_box = Box::{ left : 0, top : 0, right : a.length(), bottom : b.length() }
  let foo = find_path(initial_box, a, b)
  match foo {
    None => ()
    Some(v) => println(v.collect())
  }
}

fn main {
  let a = lines(before)
  let b = lines(after)
  let foo = linear_diff(a, b)
  match foo {
    None => ()
    Some(v) => print_diff(v)
  }
}

