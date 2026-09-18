# Huffman Coding in Scheme

A simple implementation of **Huffman coding and decoding in Scheme**.

## Overview

Huffman coding is a **lossless compression algorithm**. It reduces the amount of space needed to represent data by assigning:

* **shorter binary codes** to symbols that appear more frequently;
* **longer binary codes** to symbols that appear less frequently.

For example, suppose the input contains:

```text
A A A A B B C
```

The frequencies are:

```text
A → 4
B → 2
C → 1
```

A Huffman tree can then assign codes such as:

```text
A → 0
B → 10
C → 11
```

The original data can therefore be represented by a sequence of bits instead of using the same number of bits for every symbol.

Huffman coding is **lossless**, meaning that decoding the encoded bit sequence with the corresponding Huffman tree reconstructs the original data exactly.

## How Huffman Coding Works

The algorithm used in this project is:

1. Count the frequency of every unique symbol.
2. Create one leaf node for every symbol.
3. Sort the nodes by frequency.
4. Take the two nodes with the smallest frequencies.
5. Combine them into a new tree whose frequency is the sum of the two frequencies.
6. Insert the new tree back into the list and sort again.
7. Repeat until only one tree remains.
8. Traverse the final tree to generate a binary code for every symbol.
9. Encode the original input using those codes.

The two smallest-frequency nodes are combined first, so less frequent symbols generally end up deeper in the tree and receive longer codes.

## Decoding

Decoding reverses the process:

1. Start at the root of the Huffman tree.
2. Read the next bit.
3. `0` means move to the left child.
4. `1` means move to the right child.
5. When a leaf is reached, output its symbol.
6. Return to the root and continue with the remaining bits.

This works because Huffman codes are **prefix-free**: no valid symbol code is the prefix of another valid symbol code.

## Data Representation

The implementation represents a frequency list as an association list:

```scheme
'((a . 3) (b . 2) (c . 1))
```

Each Huffman tree node is represented as:

```text
(root left-child right-child)
```

A leaf contains a frequency-symbol pair and has no children:

```scheme
((3 . a) () ())
```

An internal node contains the **sum of the frequencies of its two children**:

```scheme
((5) left-tree right-tree)
```

For example, combining nodes with frequencies `2` and `3` produces an internal node with frequency `5`:

```text
        5
       / \
      2   3
```

Therefore:

* `(car tree)` accesses the node's root data;
* `(cadr tree)` accesses the left child;
* `(caddr tree)` accesses the right child.

## Function Overview

### `findFrequencyOf`

```scheme
(findFrequencyOf elem l eq2)
```

Counts how many times `elem` occurs in `l`.

`eq2` is the equality function used to compare elements.

Example:

```scheme
(findFrequencyOf 'a '(a b a c a) equal?)
; → 3
```

---

### `unique?`

```scheme
(unique? elem l eq2)
```

Checks if `elem` is in `l`.

It returns:

* `#t` when the element is not found;
* `#f` when the element is found.

This is used to avoid counting the same symbol more than once.

---

### `unique?2`

```scheme
(unique?2 elem l eq2)
```

The association-list version of `unique?`.

Instead of searching for `elem` directly, it checks the first element of each pair.

For example:

```scheme
'((a . 3) (b . 2) (c . 1))
```

---

### `frequencyList`

```scheme
(frequencyList l eq2 alreadyCounted)
```

Builds the frequency list for the input.

For example:

```scheme
(frequencyList '(a b a c a b) equal? '())
; → ((a . 3) (b . 2) (c . 1))
```

`alreadyCounted` keeps track of symbols whose frequencies have already been added.

---

### `frequencyList2`

```scheme
(frequencyList2 l eq2 assoc)
```

An alternative implementation of the same frequency-list step.

Instead of maintaining a separate `alreadyCounted` list, it checks the association list that is being built.

---

### `leafList`

```scheme
(leafList freqList)
```

Converts a frequency list into a list of Huffman leaf trees.

For example:

```scheme
'((a . 3) (b . 2))
```

becomes conceptually:

```scheme
'(
  ((3 . a) () ())
  ((2 . b) () ())
)
```

---

### `sortTrees`

```scheme
(sortTrees trees)
```

Sorts the list of Huffman trees in **ascending order of frequency**.

The implementation uses a **quicksort algorithm**.

The first tree is used as the pivot, and the remaining trees are divided into two groups:

* trees with a smaller frequency than the pivot;
* trees with a frequency greater than or equal to the pivot.

Both groups are then sorted recursively and combined with the pivot.

The Huffman construction relies on the first two elements being the two smallest-frequency trees.

---

### `newTree`

```scheme
(newTree t1 t2)
```

Combines two Huffman trees into a new parent tree.

The frequency stored in the new parent is the **sum of the frequencies of its two children**.

For example, suppose we have:

```scheme
t1 = ((2 . a) () ())
t2 = ((3 . b) () ())
```

The frequencies of the two trees are:

```text
t1 → 2
t2 → 3
```

`newTree` adds them together:

```text
2 + 3 = 5
```

and creates:

```scheme
((5) t1 t2)
```

Conceptually, the resulting tree is:

```text
        5
       / \
      2   3
      a   b
```

This operation is the core of Huffman tree construction. Repeatedly combining the two trees with the smallest frequencies eventually produces a single Huffman tree.

---

### `leafsToTree`

```scheme
(leafsToTree leafs)
```

Builds the complete Huffman tree.

It repeatedly:

```text
take the two smallest trees
        ↓
combine them
        ↓
insert the result
        ↓
sort again
        ↓
repeat
```

The final result is a list containing one remaining tree.

---

### `symbolToBinary`

```scheme
(symbolToBinary tree symbol eq2 binaryL)
```

Finds the binary path from the root of the Huffman tree to a given symbol.

While traversing:

* going left adds `#\0`;
* going right adds `#\1`.

`binaryL` stores the path accumulated so far.

For example, a symbol reached through:

```text
left → right → left
```

gets:

```scheme
'(#\0 #\1 #\0)
```

---

### `treeToBinary`

```scheme
(treeToBinary tree l eq2)
```

Encodes every symbol in `l` using the Huffman tree.

It calls `symbolToBinary` for each input symbol and appends the resulting bit lists into one binary list.

---

### `HuffmanCoding`

```scheme
(HuffmanCoding l eq2)
```

Runs the complete encoding pipeline:

```text
input
  ↓
frequencyList
  ↓
leafList
  ↓
sortTrees
  ↓
leafsToTree
  ↓
Huffman tree
  ↓
treeToBinary
  ↓
encoded binary
```

The function returns:

```scheme
(cons tree binary)
```

so the result contains both:

1. the Huffman tree;
2. the encoded binary sequence.

Example:

```scheme
(define result
  (HuffmanCoding l equal?))
```

---

### `HuffmanDecodingHelper`

```scheme
(HuffmanDecodingHelper tree currTree binary)
```

Performs the recursive tree traversal used during decoding.

For every bit:

* `#\0` → left child;
* `#\1` → right child.

When a leaf is reached, its symbol is added to the result and traversal restarts from the root.

---

### `HuffmanDecoding`

```scheme
(HuffmanDecoding tree binary)
```

The public decoding function.

It starts the recursive helper at the root of the Huffman tree:

```scheme
(HuffmanDecodingHelper tree tree binary)
```

Conceptually:

```text
Huffman tree + binary
        ↓
   tree traversal
        ↓
     symbols
```

## Complete Pipeline

The complete implementation can be viewed as:

```text
                  INPUT
                    │
                    ▼
             frequencyList
                    │
                    ▼
                leafList
                    │
                    ▼
               sortTrees
                    │
                    ▼
              leafsToTree
                    │
                    ▼
              HUFFMAN TREE
                    │
                    ▼
             treeToBinary
                    │
                    ▼
             ENCODED BITS
                    │
                    ▼
            HuffmanDecoding
                    │
                    ▼
                ORIGINAL
                 INPUT
```

## Usage

### Encoding

```scheme
(define result
  (HuffmanCoding l equal?))
```

`result` contains:

```text
(tree . binary)
```

### Decoding

```scheme
(HuffmanDecoding (car result) (cdr result))
```

The decoded result should match the original input:

```scheme
(equal? (HuffmanDecoding (car result) (cdr result)) l)
; → #t
```

## Notes and Edge Cases

### Equality Function

The implementation accepts an equality function such as:

```scheme
equal?
```

through the `eq2` parameter. This allows the code to work with different kinds of Scheme values, provided the supplied comparison function is appropriate.

### Empty Input

`HuffmanCoding` handles an empty input by producing an empty tree and empty encoded output.

### Single-Symbol Input

A one-symbol input is a special case in Huffman coding because there is only one leaf and no left/right path. If single-symbol inputs are expected, the implementation may need an explicit convention (for example, assigning the only symbol the code `0`) to ensure encoding and decoding behave consistently.

### Complexity

The implementation is intentionally recursive and educational.

In particular, `sortTrees` uses a quicksort-style approach that repeatedly partitions and reconstructs lists. Therefore, this implementation is not intended to be an optimized production implementation. Its main purpose is to make the Huffman algorithm explicit and easy to follow.

## Summary

This project implements the main stages of Huffman compression:

```text
frequency counting
      ↓
tree construction
      ↓
binary encoding
      ↓
tree-based decoding
```

Because the process is lossless, the encoded data can be decoded back to the original symbols as long as the same Huffman tree is available.
