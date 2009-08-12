data Color = R | B | BB deriving (Show, Eq) -- BB is doubly black, used for deletion
data RBTree a = Empty
              | Node Color (RBTree a) a (RBTree a)

-- helper functions
key::RBTree a -> a
key (Node _ _ k _) = k

left::RBTree a -> RBTree a
left (Node _ l _ _) = l
left _ = Empty

isEmpty::RBTree a -> Bool
isEmpty Empty = True
isEmpty _ = False

mint::RBTree a -> RBTree a
mint t = if isEmpty (left t) then t else mint $ left t

-- Insertion/Deletion
insert::(Ord a)=>RBTree a -> a -> RBTree a
insert t x = makeBlack(ins t x) where  --[1]
    ins Empty x = Node R Empty x Empty --[2]
    ins (Node color l k r) x 
        | x < k     = balance color (ins l x) k r
        | otherwise = balance color l k (ins r x) --[3]
    makeBlack(Node _ l k r) = Node B l k r

{- footnotes
[1]: Always set the root color as black;
[2]: new node is inserted as a red leaf, 
     to reserve property 1, 3, 5, only property 2, 4 may be violated
[3]: All keys should be indentical -}

-- Core function for insert, to make the tree balanced after insertion.
-- refer to paper of [Chris Okasaki]
balance::Color -> RBTree a -> a -> RBTree a -> RBTree a
balance B (Node R (Node R a x b) y c) z d = Node R (Node B a x b) y (Node B c z d) -- case 1
balance B (Node R a x (Node R b y c)) z d = Node R (Node B a x b) y (Node B c z d) -- case 2
balance B a x (Node R b y (Node R c z d)) = Node R (Node B a x b) y (Node B c z d) -- case 3
balance B a x (Node R (Node R b y c) z d) = Node R (Node B a x b) y (Node B c z d) -- case 4
balance color l k r = Node color l k r

delete::(Ord a)=>RBTree a -> a -> RBTree a
delete t x = del t x where
    del Empty _ = Empty
    del (Node color l k r) x 
       | x < k = fixDB color (del l x) k r
       | x > k = fixDB color l k (del r x)
       -- x == k, delete this node
       | isEmpty l = if color==B then makeBlack r else r
       | isEmpty r = if color==B then makeBlack l else l
       | otherwise = fixDB color l k' (del r k') where k'= key $ mint r

makeBlack::RBTree a -> RBTree a
makeBlack (Node B l k r) = (Node BB l k r) -- doubly black
makeBlack (Node _ l k r) = (Node B l k r)
makeBlack t = t

-- Core function for delete, to solve the uniform black height violation.
-- refer to CLRS
fixDB::Color -> RBTree a -> a -> RBTree a -> RBTree a
-- the sibling is black, and it has one red child
fixDB color a@(Node BB _ _ _) x (Node B (Node R b y c) z d) = Node color (Node B a x b) y (Node B c z d)
fixDB color a@(Node BB _ _ _) x (Node B b y (Node R c z d)) = Node color (Node B a x b) y (Node B c z d)
fixDB color (Node B a x (Node R b y c)) z d@(Node BB _ _ _) = Node color (Node B a x b) y (Node B c z d)
fixDB color (Node B (Node R a x b) y c) z d@(Node BB _ _ _) = Node color (Node B a x b) y (Node B c z d)
-- the sibling and its 2 children are all black, propagate the blackness up
fixDB color a@(Node BB _ _ _) x (Node B b@(Node B _ _ _) y c@(Node B _ _ _))
    = makeBlack (Node color a x (Node R b y c))
fixDB color (Node B a@(Node B _ _ _) x b@(Node B _ _ _)) y c@(Node BB _ _ _)
    = makeBlack (Node color (Node R a x b) y c)
-- the sibling is red
fixDB B a@(Node BB _ _ _) x (Node R b y c) = fixDB B (fixDB R a x b) y c
fixDB B (Node R a x b) y c@(Node BB _ _ _) = fixDB B a x (fixDB R b y c)
-- otherwise
fixDB color l k r = Node color l k r

-- helper function to build a red black tree from a list

listToRBTree::(Ord a)=>[a] -> RBTree a
listToRBTree lst = foldl insert Empty lst

-- Helper function for pretty printing
instance Show a => Show (RBTree a) where
    show Empty = "."
    show (Node c l k r) = "(" ++ show l ++ " " ++ 
                          show k ++ ":" ++ show c ++ " " ++ 
                          show r ++ ")"

-- test cases
t1=listToRBTree [11, 2, 14, 1, 7, 15, 5, 8, 4]
t2=Node B (Node R Empty 4 Empty) 5 Empty

testDel = "\ntest del 4: " ++ show (delete t1 4) ++
          "\ntest del 5: " ++ show (delete t1 5) ++
          "\ntest del 2: " ++ show (delete t1 2) ++
          "\ntest del 7: " ++ show (delete t1 7) ++
          "\ntest del 14: " ++ show (delete t1 14) ++
          "\ntest del t2 4: " ++ show (delete t2 4)

main = do
  putStrLn $ show t1
  putStrLn $ show (listToRBTree [1, 2, 3, 4, 5, 6, 7, 8])
  putStrLn testDel

{- Reference 
[Chris Okasaki] Functional Pearls Red-Black trees in a functional setting.
   J. Functional programming. Jan. 1999.
   http://www.eecs.usma.edu/webs/people/okasaki/jfp99.ps-}