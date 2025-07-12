lui     $s0,    0x00ff          # $s0 = 0x00ff_0000
addi    $s1,    $s1,    3       # $s1 = 0x0000_0003
add     $s2,    $s1,    $s0     # $s2 = 0x00ff_0003
addu    $s3,    $s2,    $s1     # $s3 = 0x00ff_0006
sub     $s4,    $s3,    $s2     # $s4 = 0x0000_0003
subu    $s5,    $s4,    $s3     # $s5 = 0xff00_fffd
srl     $s6,    $s5,    6       # $s6 = 0x03fc_03ff
addi    $s7,    $s7,    3       # $s7 = 0x0000_0003
mul     $s0,    $s6,    $s7     # $s0 = 0x0bf4_0bfd
addiu   $s1,    $s0,    0x14    # $s1 = 0x0bf4_0c11
and     $s2,    $s2,    $s1     # $s2 = 0x00f4_0001
andi    $s3,    $s2,    1       # $s3 = 0x0000_0001
or      $s4,    $s3,    $s1     # $s4 = 0x0bf4_0c11
xor     $s5,    $s4,    $s3     # $s5 = 0x0bf4_0c10
xor     $s6,    $s6,    $s5     # $s6 = 0x0808_0fef
nor     $s7,    $s6,    $s5     # $s7 = 0xf403_f000
andi    $s0,    $s7,    1023    # $s0 = 0x0000_0000
sll     $s1,    $s0,    1       # $s1 = 0x0000_0000
sra     $s2,    $s1,    3       # $s2 = 0x0000_0000
slt     $s3,    $s2,    $s1     # $s3 = 0x0000_0000
slti    $s4,    $s3,    0x10    # $s4 = 0x0000_0001
sltu    $s5,    $s4,    $s3     # $s5 = 0x0000_0000
sltiu   $s6,    $s5,    0x20    # $s6 = 0x0000_0001
ori     $s7,    $s6,    0x0010  # $s7 = 0x0000_0011
lui     $a0,    0x4000          # $a0 = 0x4000_0000
addi    $a0,    $a0,    0x10    # $a0 = 0x4000_0010
sw      $s2,    0($a0)
lw      $s7,    0($a0)
addi    $s7,    $s7,    1
sw      $s7,    0($a0)
sw      $s6,    0($a0)
# s2 = 0x0000_00fa
# s7 = 0x0000_00fb
# s6 = 0x0000_0001
