#include <iostream>
#include <cstdlib>
#include <cstdio>

using namespace std;

template<typename T>
struct Node {
  T key;
  Node* next;

  Node(): next(0) {}
  Node(T x) : key(x), next(0) {}
  Node(T x, Node* n) : key(x), next(n) {}
  ~Node() { delete next; }
};

template<typename T>
struct List {
  Node<T>* head;
  Node<T>* tail;

  List() : head(0), tail(0) {}
  List(Node<T>* h, Node<T>* t) : head(h), tail(t) {}
};

template<typename T>
List<T> make(Node<T>* head, Node<T>* tail) {
  if (!tail || !head) /* Trick: it actualy handles (nil, nil), and (_, nil) cases, the later is a singleton. */
    tail = head;
  return List<T>(head, tail);
}

template<typename T>
void release(List<T> lst) {
  delete lst.head;
}

template<typename T>
bool empty(List<T> lst) { return !lst.head; }

template<typename T>
List<T> empty() { return List<T>(); }

template<typename T>
T first(List<T> lst) { return lst.head->key; }

template<typename T>
List<T> rest(List<T> lst) { 
  return make(lst.head->next, lst.tail);
}

template<typename T>
List<T> cons(T x, List<T> lst) {
  return make(new Node<T>(x, lst.head), lst.tail);
}

template<typename T>
int length(List<T> lst) {
  int n = 0;
  for (Node<T>* xs = lst.head; xs; ++n, xs = xs->next);
  return n;
}

/* 
 * Assume 0 <= n < length(lst) 
 * The bound check is skipped.
 */
template<typename T>
T getAt(List<T> lst, int n) {
  Node<T>* xs = lst.head;
  while(n--)
    xs = xs->next;
  return xs->key;
}

template<typename T>
List<T> append(List<T> lst, T x) {
  Node<T>* n = new Node<T>(x);
  if (empty(lst))
    return make(n, n);
  lst.tail->next = n;
  return make(lst.head, n);
}

/* Suppose the input list isn't empty. */
template<typename T>
T last(List<T> lst) {
  T x; /* Can be initialized to a special value to indicate empty list err. */
  for (Node<T>* xs = lst.head; xs; xs = xs->next)
    x = xs->key;
  return x;
}

/* Suppose the input list isn't empty. */
template<typename T>
List<T> init(List<T> lst) {
  List<T> r = empty<T>();
  for (Node<T>* xs = lst.head; xs->next; xs = xs->next)
    r = append(r, xs->key);
  return r;
}

template<typename T>
void print_lst(List<T> lst) {
  for(Node<T>* xs = lst.head; xs; xs = xs->next)
    cout<<xs->key<<", ";
  cout<<"\n";
}

int main(int, char**) {
  int i, n;
  List<int> lst = cons(1, cons(2, cons(3, empty<int>())));
  printf("length of empty = %d, len([1, 2, 3]) = %d\n", length<int>(empty<int>()), length(lst));
  lst = append(lst, 4);
  printf("append 4 ==>");
  print_lst(lst);
  n = length(lst);
  for(i = 0; i < n; ++i)
    printf("lst[%d] = %d%s", i, getAt(lst, i), i == n-1 ? "\n" : ", ");
  printf("last(lst) = %d, init(lst) = ", last(lst));
  print_lst(init(lst));
  release(lst);
}
