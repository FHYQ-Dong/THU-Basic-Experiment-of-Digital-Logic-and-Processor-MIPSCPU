addi        $t0,    $t0,    0x00ff # $t0 = 0x0000_00ff
    addi    $t1,    $t0,    1      # $t1 = 0x0000_0100
    addi    $t2,    $t0,    2      # $t2 = 0x0000_0101
    addi    $t3,    $zero,  -2     # $t3 = -2
    addi    $t4,    $zero,  2      # $t4 = 2
l1: addi    $t0,    $t0,    1      # $t0 = 0x0000_0100
    beq     $t0,    $t1,    l1     # beq once
    bne     $t0,    $t2,    l1     # no bne
l2: addi    $t3,    $t3,    1      # $t3 = -1
    bltz    $t3,    l2             # bltz once
    blez    $t3,    l2             # blez once
l3: addi    $t4,    $t4,    -1     # $t4 = 1
    bgtz    $t4,    l3             # bgtz once
    j       j1                     # jump to j1
    addi    $s0,    $s0,    0x0fff # no effect, $s0 = 0
j1: jal     j2                     # jump to j2
    addi    $s2,    $s2,    0x0fff # after jr, $s2 = 0x0000_0fff
    j       j3                     # jump to j3
j2: addi    $s1,    $s1,    0x00ff # $s1 = 0x0000_00ff   
    jr      $ra                    # return to j2's next instruction
j3: jal     j4                     # jump to j4 (to set $ra for jalr)
    addi    $s4,    $s4,    0x00ff # after jalr, $s4 = 0x0000_00ff
    j       j5                     # jump to j5
j4: add 	$v0,	$ra,	$zero  # $v0 = $ra
    jalr    $s3,    $v0            # jump to $s3 == $ra, $v0 = PC+4
j5: jal	    j6                     # jump to j6
    j	    ed                     # jump to ed
j6: sw	    $ra,	0($zero)       # store $ra to 0($zero)
    lw	    $v0,	0($zero)       # load $v0 from 0($zero)
    jr	    $v0                    # jump to $v0 (test lw-jal)
ed: addi    $s5,    $s5,    0x00ff # end, $s5 = 0x0000_00ff
