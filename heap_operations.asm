# HEAP OPERATIONS

.globl insert , extractMin
      
   
#$a0 -- i
# Function to return the index of the parent
# parent node of a given node
#retuen in $v0
parent:

subi $sp, $sp, 4     # adjust stack to make room for 1 items
sw   $a0, 0($sp)     # save register $a0

subi $a0,$a0,1	     # i-1
srl  $a0,$a0,1       #(i-1)/2
move $v0,$a0         # return at $v0

lw   $a0, 0($sp)     # restore $a0
addi $sp, $sp, 4     # restore stack or 1 items

jr   $ra

#$a0 -- i
# Function to return the index of the left child
# left child of the given node
#retuen in $v0
leftChild:
subi $sp, $sp, 4     # adjust stack to make room for 1 items
sw   $a0, 0($sp)     # save register $a0

sll  $a0,$a0,1       #2*i
addi $a0,$a0,1	     #2*i + 1 
move $v0,$a0	     # return at $v0

lw   $a0, 0($sp)     # restore $a0
addi $sp, $sp, 4     # restore stack or 1 items

jr   $ra

#$a0 -- i
# Function to return the index of the right child
# right child of the given node
#retuen in $v0
rightChild:

subi $sp, $sp, 4     # adjust stack to make room for 1 items
sw   $a0, 0($sp)     # save register $a0

sll $a0,$a0,1        #2*i
addi $a0,$a0,2	     #2*i + 2 
move $v0,$a0	     # return at $v0

lw   $a0, 0($sp)     # restore $a0
addi $sp, $sp, 4     # restore stack or 1 items


jr   $ra

#$a0 -- i
# Function to shift up the node in order
# to maintain the heap property
# don't have a retuen value
shiftUp:
subi $sp, $sp, 24     # adjust stack to make room for 5 items
sw   $t5, 20($sp)     # save register $t5
sw   $t4, 16($sp)     # save register $t4 
sw   $t3, 12($sp)     # save register $t3  H[i]
sw   $t2, 8($sp)      # save register $t2  --> H[parent(i)]
sw   $t1, 4($sp)      # save register $t1 for conditioning
sw   $t0, 0($sp)      # save register $t0  for i

move $t0,$a0

loop:

#if(0 < i && H[parent(i)] < H[i])
slt $t1,$0,$t0         #0 < i

subi $sp, $sp,8        # adjust stack for 2 items
sw   $ra, 4($sp)       # save the return addres
sw   $a0,0($sp)	       # save the parmeter register

move $a0,$t0
jal parent             #parent(i)

lw $a0,0($sp)          # restore the parmeter register
lw $ra, 4($sp)         #restore the return address 
addi $sp, $sp, 8       # adjust stack for 2 items 


sll $t0,$t0,2          #adjust offset
sll $v0,$v0,2	       #adjust offset
lw  $t2,pq($v0)       #H[parent(i)]
lw  $t3,pq($t0)       #H[i]

andi $t5 , $t2 , 0xffff # 1011110111   --> and 1111 --> 0111
andi $t6 , $t3 , 0xffff

slt $t4,$t6,$t5        #H[parent(i)] > H[i]

and $t7,$t4,$t1
beq $t7,$0,exit0 

#swap(H[parent(i)], H[i]);
sw  $t2,pq($t0)
sw  $t3,pq($v0)
srl $v0,$v0,2

# Update i to parent of i
move $t0,$v0   #i = parent(i);
j loop

exit0:
lw   $t0, 0($sp)     # restore register $t0 for caller
lw   $t1, 4($sp)     # restore register $t1 for caller
lw   $t2, 8($sp)     # restore register $t2 for caller
lw   $t3, 12($sp)    # restore register $t3 for caller
lw   $t4, 16($sp)    # restore register $t4 for caller
lw   $t5, 20($sp)    # restore register $t5 for caller
addi $sp,$sp,24      # adjust stack to delete 5items

jr   $ra


# Function to shift down the node in
# order to maintain the heap property
# don't have a retuen value
shiftDown:
subi $sp, $sp,32      # adjust stack to make room for 8 items
sw   $t7, 28($sp)     # save register $t7  h[i]
sw   $t6, 24($sp)     # save register $t6  for condition
sw   $t5, 20($sp)     # save register $t5  h[l] or h[r]
sw   $t4, 16($sp)     # save register $t4  h[minIndex] 
sw   $t3, 12($sp)     # save register $t3  for condition
sw   $t2, 8($sp)      # save register $t2  for size
sw   $t1, 4($sp)      # save register $t1  for l --> leftChild or r --> rightChild
sw   $t0, 0($sp)      # save register $t0  for maxIndex

move $t0,$a0

subi $sp, $sp, 4       # adjust stack for 1 items
sw $ra, 0($sp)         # save the return addres
jal leftChild          # leftChild(i)
move $t1,$v0 	       # l = leftChild(i)
lw $ra, 0($sp)         #restore the return address 
addi $sp, $sp, 4       # restore stack for 1 items


# if (l <= siz && H[minIndex] > H[l])
lw $t2,size

sle $t3,$t1,$t2         #l <= size
sll $t0,$t0,2
lw  $t4,pq($t0)        #h[minIndex]
srl $t0,$t0,2

sll $t1,$t1,2
lw  $t5,pq($t1)         #h[l]
srl $t1,$t1,2

andi $t7 , $t4 , 32767
andi $t8 , $t5 , 32767
#H[minIndex] > H[l]
slt $t6,$t8,$t7    
and $t6,$t6,$t3
beq $t6,$0,exit1
move $t0,$t1  	       # minIndex = r;
exit1:

subi $sp, $sp, 4       # adjust stack for 1 items
sw $ra, 0($sp)         # save the return addres
jal rightChild	       # rightChild(i);
move $t1,$v0	       # r = rightChild(i);
lw $ra, 0($sp)         # restore the return address 
addi $sp, $sp, 4       # restore stack for 1 items

# if (l <= siz && H[minIndex] > H[r])
sle $t3,$t1,$t2        # r <= size

sll $t0,$t0,2
lw $t4,pq($t0)        # h[maxIndex]
srl $t0,$t0,2

sll $t1,$t1,2
lw  $t5,pq($t1)       # h[r]
srl $t1,$t1,2

sll $t7 , $t4,16
sll $t8 , $t5,16
#H[minIndex] > H[r]
slt $t6,$t8,$t7
and $t6,$t6,$t3
beq $t6,$0,exit2

move $t0,$t1          # minIndex = l;

exit2:

# If i not same as maxIndex

beq $a0,$t0,exit3

# swap(H[i], H[minIndex]);
#$a0-->i
#$t0--->maxIndex

sll $a0,$a0,2
lw  $t7,pq($a0)       # $t7 = h[i]


sll $t0,$t0,2
lw  $t4,pq($t0)       # t4 = h[maxIndex]

sw  $t4,pq($a0)       # h[i] = $t4
srl $a0,$a0,2


sw  $t7,pq($t0)       # h[max] = $t7
srl $t0,$t0,2

subi $sp, $sp, 8       # adjust stack for 2 items
sw   $ra, 4($sp)       # save the return addres
sw   $a0, 0($sp)       # save the paramter
move $a0,$t0           # put maxIndex in $a0
jal shiftDown
lw $a0, 0($sp)         # restore the paramter
lw $ra, 4($sp)         #restore the return address 
addi $sp, $sp, 8       # restore stack for 1 items 


exit3:
lw   $t0, 0($sp)     # restore register $t0 for caller
lw   $t1, 4($sp)     # restore register $t1 for caller
lw   $t2, 8($sp)     # restore register $t2 for caller
lw   $t3, 12($sp)    #restore register  $t3 for caller
lw   $t4, 16($sp)    # restore register $t4 for caller
lw   $t5, 20($sp)    # restore register $t5 for caller
lw   $t6, 24($sp)    # restore register $t6 for caller
lw   $t7, 28($sp)    # restore register $t7 for caller
addi $sp,$sp,32      # adjust stack to delete 8 items
jr $ra

# Function to insert a new element
# in the Binary Heap
#a0--> parameter
insert:

subi $sp, $sp, 4      # adjust stack to make room for 1 items
sw   $t0, 0($sp)      # save register $t0 for storing size

lw   $t2,size     
addi $t2,$t2,1         # siz + 1;

sll  $t2,$t2,2
sw   $a0,pq($t2)      # H[size] = p;
srl  $t2,$t2,2

move $a0,$t2
sw   $t2,size	       # size = size + 1;
move $a0,$t2

subi $sp, $sp, 4       # adjust stack for 1 items
sw   $ra, 0($sp)       # save the return addres
jal  shiftUp           #Shift Up to maintain heap property
lw   $ra, 0($sp)       #restore the return address
addi $sp, $sp, 4       # adjust stack for 1 items

lw $t0, 0($sp)         # restore register $t0 for caller
addi $sp,$sp,4         # adjust stack to delete 1 items
jr   $ra


# Function to extract the element with
# minimum priority
# return minimum value in $v0
extractMin:
subi $sp, $sp, 12     # adjust stack to make room for 3 items
sw   $t2, 8($sp)      # save register $t2  H[siz];
sw   $t1, 4($sp)      # save register $t1 size
sw   $t0, 0($sp)      # save register $t0    result = h[0] 

lw $t0,pq  #h[0]

#  Replace the value at the root
# with the last leaf
lw $t1,size
sll $t1,$t1,2
lw $t2,pq($t1) #H[siz]
sw $t2,pq # H[0] = H[siz];
srl $t1,$t1,2

subi $t1,$t1,1   # siz - 1
sw $t1,size      # siz = siz - 1

#Shift down the replaced element
#to maintain the heap property

subi $sp, $sp, 8       # adjust stack for 1 items
sw $ra, 4($sp)         # save the return addres
sw $a0, 0($sp)         # save the return addres
li $a0,0
jal shiftDown	       #shiftDown(0)
lw $a0, 0($sp)         #restore the return address 
lw $ra, 4($sp)         #restore the return address 
addi $sp, $sp, 8       # restore stack for 1 items

move $v0,$t0           # return result in $v0

lw   $t0, 0($sp)       # restore register $t0 for caller
lw   $t1, 4($sp)       # restore register $t1 for caller
lw   $t2, 8($sp)       # restore register $t2 for caller
addi $sp,$sp,12        # adjust stack to delete 
jr   $ra
   
   
