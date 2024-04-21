你使用过Unix下的小工具`diff`吗？没有也没关系，简而言之，它是一个比对两个文本文件之间有什么不同之处的工具。它的作用不止于此，Unix下还有一个叫`patch`的小工具

时至今日，很少有人手动为某个软件包打补丁了，但`diff`在另一个地方仍然保留着它的作用：版本管理系统。能够看见某一次提交之后的源码文件发生了哪些变化(并且用不同颜色标出来)是个很有用的功能. 我们以当今最流行的版本管理系统git为例，它可以

```diff
diff --git a/main/main.mbt b/main/main.mbt
index 99f4c4c..52b1388 100644
--- a/main/main.mbt
+++ b/main/main.mbt
@@ -3,7 +3,7 @@
 
 fn main {
   let a = lines("A\nB\nC\nA\nB\nB\nA")
-  let b = lines("C\nB\nA\nB\nA\nC")
+  let b = lines("C\nB\nA\nB\nA\nA")
   let r = shortst_edit(a, b)
   println(r)
 }
```

但是，究竟怎样计算出两个文本文件的差别呢？

git的默认diff算法是*Eugene W. Myers*在他的论文**An O(ND) Difference Algorithm and Its Variations**中所提出的，这篇论文的pdf可以在网上找到，但论文内容主要集中于证明该算法的正确性。在下文中，我们将以不那么严谨的方式了解该算法的基本框架，并且使用MoonBit编写该算法的一个简单实现。

## 定义"差别"及其、

当我们谈论两段文本的"差别"时，我们说的其实是一系列的编辑动作，通过执行这段动作，我们可以把文本a转写成文本b。

假设文本a的内容是

```
A
B
C
A
B
B
A
```

文本b的内容是

```
C
B
A
B
A
C
```

要把文本a转写成文本b，最简单的编辑序列是删除每一个a中的字符(用减号表示)，然后插入每一个b中的字符(用加号表示)

```diff
- A
- B
- C
- A
- B
- B
- A
+ C
+ B
+ A
+ B
+ A
+ C
```

但这样的结果对阅读代码的程序员可能没有什么帮助，而下面这个编辑序列就好很多，至少它比较短

```diff
- A
- B
  C
+ B
  A
  B
- B
  A
+ C
```

实际上，它是最短的可以将文本a转写成文本b的编辑序列之一，总共有5个动作。如果仅仅以编辑序列长度作为衡量标准，这个结果足以让我们满意。但当我们审视现实中已经存在的各种编程语言，我们会发现在此之外还有一些对用户体验同样重要的指标，让我们看看下面这两个例子：

```diff
// 质量好
  struct RHSet[T] {
    set : RHTable[T, Unit]
  }
+ 
+ fn RHSet::new[T](capacity : Int) -> RHSet[T] {
+  let set : RHTable[T, Unit]= RHTable::new(capacity)
+  { set : set }
+ }


// 质量不好
  struct RHSet[T] {
    set : RHTable[T, Unit]
+ }
+ 
+ fn RHSet::new[T](capacity : Int) -> RHSet[T] {
+  let set : RHTable[T, Unit]= RHTable::new(capacity)
+  { set : set }
  }
```

当我们在文件末尾处插入了一个新的函数定义，那计算出的编辑序列最好把更改都集中在后面。还有些类似的情况，当同时存在删除和插入时，最好不要计算出一个两种操作交织穿插的编辑序列，下面是另一个例子。

```
Good:   - one         Bad:    - one
        - two                 + four
        - three               - two
        + four                + five
        + five                + six
        + six                 - three
```

myers的diff算法能够满足我们在上面提到的这些需求，它是一种贪心算法，会尽可能地跳过相同的行(避免了在`{`前面插入文本的情况)，同时它还会尽可能地把删除安排在插入前面，这又避免了后面一种情况。

