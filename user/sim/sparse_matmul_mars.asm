# This file is used to get the instruction count of the sparse matrix multiplication function in MARS simulator.
.data
    mat:    .word   0x00000003, 0x00000004, 0x00000005, 0x00000004, 
                    0x00000009, 0x00000007, 0x0000000f, 0x00000009, 
                    0x00000002, 0x00000001, 0x00000000, 0x00000002, 
                    0x00000000, 0x00000001, 0x00000002, 0x00000004, 
                    0x00000001, 0x00000004, 0x00000000, 0x0000000c, 
                    0x0000000b, 0x00000009, 0x00000000, 0x0000000b, 
                    0x00000008, 0x00000002, 0x0000000c, 0x00000002, 
                    0x0000000b, 0x0000000a, 0x00000000, 0x0000000a, 
                    0x0000000c, 0x00000000, 0x00000001, 0x00000009

.text
    la      $t0,    0x00000000
    lw      $s0,    0x10010000($t0)                 # $s0: m
    lw      $s1,    0x10010004($t0)                 # $s1: n
    lw      $s2,    0x10010008($t0)                 # $s2: p
    lw      $s3,    0x1001000c($t0)                 # $s3: s

    addi    $s4,    $t0,                16          # $s4: values

    sll     $s5,    $s3,                2
    add     $s5,    $s5,                $s4         # $s5: col_indices

    sll     $s6,    $s3,                3
    add     $s6,    $s6,                $s4         # $s6: row_ptr

    addi    $s7,    $s0,                1
    sll     $s7,    $s7,                2
    add     $s7,    $s7,                $s6         # $s7: B
    # set zeros
    li      $t0,    0                               # int i = 0;
    mul     $v1,    $s0,                $s2         # $v1: m * p
    loop_0  :
    bge     $t0,    $v1,                end_loop_0  # if (i < m * p) next, otherwise to end_loop_0

    la      $t1,    0x00000100                      # $t1: C
    mul     $t2,    $t0,                4           # $t2: (int*)%i;
    add     $t1,    $t1,                $t2         # $t1 = C + i;
    sw      $zero,  0x10010000($t1)                 # C[i] = 0;

    addi    $t0,    $t0,                1           # i++;
    j       loop_0                                  # go back to the beginning of the loop
end_loop_0:

    # the big loop, with $t3 used multiple times in different loops
    # t3: start, t4: i, t5: j, t6: k, t7: l, t8: end, t9: val
    li      $t4,    0                               # int i = 0;
    loop_3  :
    bge     $t4,    $s0,                end_loop_3  # if (i < m) next, otherwise to end_loop_3

    mul     $t8,    $t4,                4           # end = (int*)i;
    add     $t8,    $s6,                $t8         # end = row_ptr[i];
    lw      $t3,    0x10010000($t8)                 # start = row_ptr[i];
    lw      $t8,    0x10010004($t8)                 # end = row_ptr[i + 1]

    # middle loop
    add     $t5,    $zero,              $t3         # int j = start;
    loop_2  :
    bge     $t5,    $t8,                end_loop_2  # if (j < end) next, otherwise to end_loop_2

    mul     $t6,    $t5,                4           # k = (int*)j;
    add     $t6,    $s5,                $t6         # k = &col_indices[j];
    lw      $t6,    0x10010000($t6)                 # k = col_indices[j];

    mul     $t9,    $t5,                4           # val = (int*)j;
    add     $t9,    $s4,                $t9         # val = &values[j];
    lw      $t9,    0x10010000($t9)                 # val = values[j];

    # inner loop
    li      $t7,    0                               # int l = 0;
    loop_1  :
    bge     $t7,    $s2,                end_loop_1  # if (l < p) next, otherwise to end_loop_1

    mul     $t1,    $t4,                $s2         # $t1: i * p;
    add     $t1,    $t1,                $t7         # $t1 = i * p + l;
    mul     $t1,    $t1,                4           # (int*)$t1;
    la      $t3,    0x00000100                      # $t3: C
    add     $t1,    $t1,                $t3         # $t1 = &C[i * p + l];

    mul     $t2,    $t6,                $s2         # $t2: k * p;
    add     $t2,    $t2,                $t7         # $t2 = k * p + l;
    mul     $t2,    $t2,                4           # (int*)$t2;
    add     $t2,    $t2,                $s7         # $t2 = &B[k * p + l];

    lw      $t3,    0x10010000($t1)                 # $t3: c_val = C[i * p + l];
    lw      $t2,    0x10010000($t2)                 # $t2 = B[k * p + l];
    mul     $t2,    $t2,                $t9         # $t2 = val * B[k * p + l];
    add     $t3,    $t3,                $t2         # c_val = c_val + val * B[k * p + l];
    sw      $t3,    0x10010000($t1)                 # C[i * p + l] = c_val;

    addi    $t7,    $t7,                1           # l++;
    j       loop_1                                  # go back to the beginning of the loop
end_loop_1:
    addi    $t5,    $t5,                1           # j++;
    j       loop_2                                  # go back to the beginning of the loop
end_loop_2:

    addi    $t4,    $t4,                1           # i++;
    j       loop_3                                  # go back to the beginning of the loop
end_loop_3:
    mul     $v0,    $s0,                $s2         # calculate m * p;
