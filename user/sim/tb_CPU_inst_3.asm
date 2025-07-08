    # do the function
    li      $v1,            0                               # $v1 = 0: symbol of doing multiplication
    jal     sparse_matmul                                   # jump to the sparse matrix multiplication function

    # print the result by BCD LEDs
    li      $v1,            1                               # $v1 = 1: symbol of doing printing
    move    $t0,            $zero                           # $t0: outest loop variable
mat_loop:                                                   # outest loop, controlling the sequence of the whole matrix
    bge     $t0,            $v0,                end_program

    mul     $t3,            $t0,                4
    addi    $t3,            $t3,                0x00000100
    lw      $t3,            ($t3)                           # $t3: the very number to be printed this time
    li      $t1,            0                               # $t1: middle loop variable
time_loop:                                                  # middle loop, controlling the sequence of four positions' enabling
    # 4096 * 3072 is for 73.2MHz pll; beware the position order (0 to l1 or l1 to 0) when writing .xdc file
    bge     $t1,            16,               end_time    # taking turns of printing each position for 4096 loops
    li      $t2,            0
    sll     $t4,            $t1,                30          # an_i = 1 while other an's = 0, if i = $t4 (mod 4), $t4: lit position
    beq     $t4,            0xc0000000,         an3
    beq     $t4,            0x80000000,         an2
    beq     $t4,            0x40000000,         an1
    # only last two bytes are useful, while first two bytes are always zero and ignored
an0:
    li      $t4,            0x0100
    srl     $t5,            $t3,                12
    j       bcd
an1:
    li      $t4,            0x0200
    srl     $t5,            $t3,                8
    j       bcd
an2:
    li      $t4,            0x0400
    srl     $t5,            $t3,                4
    j       bcd
an3:
    li      $t4,            0x0800
    srl     $t5,            $t3,                0

bcd:                                                        # $t5: the number to be shown
    andi    $t5,            $t5,                0xf
    beq     $t5,            0x0,                is0
    beq     $t5,            0x1,                is1
    beq     $t5,            0x2,                is2
    beq     $t5,            0x3,                is3
    beq     $t5,            0x4,                is4
    beq     $t5,            0x5,                is5
    beq     $t5,            0x6,                is6
    beq     $t5,            0x7,                is7
    beq     $t5,            0x8,                is8
    beq     $t5,            0x9,                is9
    beq     $t5,            0xa,                isa
    beq     $t5,            0xb,                isb
    beq     $t5,            0xc,                isc
    beq     $t5,            0xd,                isd
    beq     $t5,            0xe,                ise
    # $t5: now to be the lit LED indices
isf:
    li      $t5,            0x71
    j       light
ise:
    li      $t5,            0x79
    j       light
isd:
    li      $t5,            0xbf
    j       light
isc:
    li      $t5,            0x39
    j       light
isb:
    li      $t5,            0xff
    j       light
isa:
    li      $t5,            0x77
    j       light
is9:
    li      $t5,            0x6f
    j       light
is8:
    li      $t5,            0x7f
    j       light
is7:
    li      $t5,            0x07
    j       light
is6:
    li      $t5,            0x7d
    j       light
is5:
    li      $t5,            0x6d
    j       light
is4:
    li      $t5,            0x66
    j       light
is3:
    li      $t5,            0x4f
    j       light
is2:
    li      $t5,            0x5b
    j       light
is1:
    li      $t5,            0x06
    j       light
is0:
    li      $t5,            0x3f

light:                                                      # $t4: to be the full code to be saved in memory, instructing LED lighting
    or      $t4,            $t4,                $t5
    sw      $t4,            0x40000010($zero)

show_loop:                                                  # innest loop, waiting with the same status
    bge     $t2,            16,               end_show    # $t2: innest loop variable
    addi    $t2,            $t2,                1           # $t2++;
    j       show_loop

end_show:
    addi    $t1,            $t1,                1           # $t1++;
    j       time_loop

end_time:
    addi    $t0,            $t0,                1           # $t0++;
    j       mat_loop

    # the main function of sparse matrix multiplication, search in the assembly homework for more detail
sparse_matmul:
    la      $t0,            0x00000000
    lw      $s0,            0($t0)                          # $s0: m
    lw      $s1,            4($t0)                          # $s1: n
    lw      $s2,            8($t0)                          # $s2: p
    lw      $s3,            12($t0)                         # $s3: s

    addi    $s4,            $t0,                16          # $s4: values

    sll     $s5,            $s3,                2
    add     $s5,            $s5,                $s4         # $s5: col_indices

    sll     $s6,            $s3,                3
    add     $s6,            $s6,                $s4         # $s6: row_ptr

    addi    $s7,            $s0,                1
    sll     $s7,            $s7,                2
    add     $s7,            $s7,                $s6         # $s7: B
    # set zeros
    li      $t0,            0                               # int i = 0;
    mul     $v1,            $s0,                $s2         # $v1: m * p
    loop_0  :
    bge     $t0,            $v1,                end_loop_0  # if (i < m * p) next, otherwise to end_loop_0

    la      $t1,            0x00000100                      # $t1: C
    mul     $t2,            $t0,                4           # $t2: (int*)%i;
    add     $t1,            $t1,                $t2         # $t1 = C + i;
    sw      $zero,          ($t1)                           # C[i] = 0;

    addi    $t0,            $t0,                1           # i++;
    j       loop_0                                          # go back to the beginning of the loop
    end_loop_0:

    # the big loop, with $t3 used multiple times in different loops
    # t3: start, t4: i, t5: j, t6: k, t7: l, t8: end, t9: val
    li      $t4,            0                               # int i = 0;
    loop_3  :
    bge     $t4,            $s0,                end_loop_3  # if (i < m) next, otherwise to end_loop_3

    mul     $t8,            $t4,                4           # end = (int*)i;
    add     $t8,            $s6,                $t8         # end = row_ptr[i];
    lw      $t3,            ($t8)                           # start = row_ptr[i];
    lw      $t8,            4($t8)                          # end = row_ptr[i + 1]

    # middle loop
    add     $t5,            $zero,              $t3         # int j = start;
    loop_2  :
    bge     $t5,            $t8,                end_loop_2  # if (j < end) next, otherwise to end_loop_2

    mul     $t6,            $t5,                4           # k = (int*)j;
    add     $t6,            $s5,                $t6         # k = &col_indices[j];
    lw      $t6,            ($t6)                           # k = col_indices[j];

    mul     $t9,            $t5,                4           # val = (int*)j;
    add     $t9,            $s4,                $t9         # val = &values[j];
    lw      $t9,            ($t9)                           # val = values[j];

    #inner loop
    li      $t7,            0                               # int l = 0;
    loop_1  :
    bge     $t7,            $s2,                end_loop_1  # if (l < p) next, otherwise to end_loop_1

    mul     $t1,            $t4,                $s2         # $t1: i * p;
    add     $t1,            $t1,                $t7         # $t1 = i * p + l;
    mul     $t1,            $t1,                4           # (int*)$t1;
    la      $t3,            0x00000100                      # $t3: C
    add     $t1,            $t1,                $t3         # $t1 = &C[i * p + l];

    mul     $t2,            $t6,                $s2         # $t2: k * p;
    add     $t2,            $t2,                $t7         # $t2 = k * p + l;
    mul     $t2,            $t2,                4           # (int*)$t2;
    add     $t2,            $t2,                $s7         # $t2 = &B[k * p + l];

    lw      $t3,            ($t1)                           # $t3: c_val = C[i * p + l];
    lw      $t2,            ($t2)                           # $t2 = B[k * p + l];
    mul     $t2,            $t2,                $t9         # $t2 = val * B[k * p + l];
    add     $t3,            $t3,                $t2         # c_val = c_val + val * B[k * p + l];
    sw      $t3,            ($t1)                           # C[i * p + l] = c_val;

    addi    $t7,            $t7,                1           # l++;
    j       loop_1                                          # go back to the beginning of the loop
    end_loop_1:
    addi    $t5,            $t5,                1           # j++;
    j       loop_2                                          # go back to the beginning of the loop
    end_loop_2:

    addi    $t4,            $t4,                1           # i++;
    j       loop_3                                          # go back to the beginning of the loop
    end_loop_3:
    mul     $v0,            $s0,                $s2         # calculate m * p;
    jr      $ra                                             # return m * p;

    # some ending animation, printing "_End" forever
end_program:
    li      $v1,            0                               # $v1 = 0: ending, $v1 is also the loop variable
    li      $t8,            -1                              # $t8: getting valid positions in $t9
    sll     $t8,            $t8,                6           # 2^6 * T is the loop cycle
    nor     $t8,            $t8,                $t8
denoument:
    srl     $t9,            $v1,                6           # $t9: $v1 mod 2^6
    and     $t9,            $t9,                $t8
    srl     $t9,            $t9,                4           # divide the loop cycle into four identical periods
    beq     $t9,            1,                  end1
    beq     $t9,            2,                  end2
    beq     $t9,            3,                  end3
end0:
    li      $t4,            0x00000279
    sw      $t4,            0x40000010($zero)               # _E__
    j       end_denoument
end1:
    li      $t4,            0x00000454
    sw      $t4,            0x40000010($zero)               # __n_
    j       end_denoument
end2:
    li      $t4,            0x0000085e
    sw      $t4,            0x40000010($zero)               # ___d
    j       end_denoument
end3:
    li      $t4,            0
    sw      $t4,            0x40000010($zero)               # -___
    j       end_denoument
end_denoument:
    addi    $v1,            $v1,                1           # $v1++;
    j       denoument
