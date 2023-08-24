addi	$t1, $zero, 148
sw	$zero, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 9
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 3
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 6
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, -1
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, -1
sw	$t0, 0($t1)
addi	$t1, $zero, 180
addi	$t0, $zero, 9
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 0
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, -1
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 3
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 4
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 1
sw	$t0, 0($t1)
addi	$t1, $zero, 212
addi	$t0, $zero, 3
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, -1
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 0
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 2
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, -1
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 5
sw	$t0, 0($t1)
addi	$t1, $zero, 244
addi	$t0, $zero, 6
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 3
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 2
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 0
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 6
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, -1
sw	$t0, 0($t1)
addi	$t1, $zero, 276
addi	$t0, $zero, -1
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 4
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, -1
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 6
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 0
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 2
sw	$t0, 0($t1)
addi	$t1, $zero, 308
addi	$t0, $zero, -1
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 1
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 5
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, -1
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 2
sw	$t0, 0($t1)
addi	$t1, $t1, 4
addi	$t0, $zero, 0
sw	$t0, 0($t1)
addi	$s0, $zero, 6
addi	$a0, $s0, 0
addi	$a1, $t0, 148
jal	dijkstra
addi	$a0, $zero, 0
addi	$t0, $zero, 1
addi	$t1, $zero, 356
print_entry:
addi	$t1, $t1, 4
lw	$t2, 0($t1)
add	$a0, $a0, $t2
addi	$t0, $t0, 1
sub	$s5, $t0, $s0
bltz	$s5, print_entry
addi	$s0, $zero, 504
addi	$t6, $zero, 2500
lui	$at, 0x4000
ori	$at, $at, 0x10
add	$t4, $zero, $at
Show:
andi	$a1, $a0, 0xf
sll	$a1, $a1, 0x2
sub	$t3, $s0, $a1
lw	$a2, 0($t3)
ori	$a2, $a2, 0x100
sw	$a2, 0($t4)
addi	$t5, $zero, 0
LoopLow1:
addi	$t5, $t5, 1
bne	$t5, $t6, LoopLow1

andi	$a2, $a0, 0xf0
srl	$a2, $a2, 0x2
sub	$t3, $s0, $a2
lw	$a1, 0($t3)
ori	$a1, $a1, 0x200
sw	$a1, 0($t4)
addi	$t5, $zero, 0
LoopLow2:
addi	$t5, $t5, 1
bne	$t5, $t6, LoopLow2

andi	$a1, $a0, 0xf00
srl	$a1, $a1, 0x6
sub	$t3, $s0, $a1
lw	$a2, 0($t3)
ori	$a2, $a2, 0x400
sw	$a2, 0($t4)
addi	$t5, $zero, 0
LoopHigh1:
addi	$t5, $t5, 1
bne	$t5, $t6, LoopHigh1

andi	$a2, $a0, 0xf000
srl	$a2, $a2, 0xa
sub	$t3, $s0, $a2
lw	$a1, 0($t3)
ori	$a1, $a1, 0x800
sw	$a1, 0($t4)
addi	$t5, $zero, 0
LoopHigh2:
addi	$t5, $t5, 1
bne	$t5, $t6, LoopHigh2
j	Show
Return:
jr	$ra
dijkstra:
addi	$a3, $a1, 0
addi	$sp, $sp, -4
sw	$ra, 0($sp)
sll	$a0, $s0, 0x2
addi	$v0, $zero, 356
addi	$a1, $v0, 0
addi	$t1, $a1, 4
addi	$v0, $zero, 380
addi	$a2, $v0, 0
addi	$t2, $a2, 4
addi	$t0, $zero, 0
addi	$t3, $zero, 1
sw	$zero, 0($a1)
sw	$t3, 0($a2)
addi	$t0, $t0, 1
sll	$t4, $t0, 0x2
add	$t4, $a3, $t4
loop1:
lw	$t5, 0($t4)
sw	$t5, 0($t1)
sw	$zero, 0($t2)
addi	$t0, $t0, 1
addi	$t1, $t1, 4
addi	$t2, $t2, 4
addi	$t4, $t4, 4
sub	$s5, $t0, $s0
bltz	$s5, loop1
addi	$t0, $zero, 0
addi	$t3, $zero, -1
loop2:
addi	$t0, $t0, 1
sub	$s5, $s0, $t0
blez	$s5, Return
addi	$t1, $zero, -1
addi	$t2, $zero, -1
addi	$t4, $zero, 0
loop3:
addi	$t4, $t4, 1
sub	$s5, $s0, $t4
blez	$s5, endLoop3
sll	$t5, $t4, 0x2
add	$t6, $t5, $a1
lw	$t6, 0($t6)
add	$t5, $t5, $a2
lw	$t5, 0($t5)
bnez	$t5, loop3
beq	$t6, $t3, loop3
bne	$t2, $t3, nextJudge1
addi	$t2, $t6, 0
addi	$t1, $t4, 0
j	loop3
nextJudge1:
sub	$s5, $t2, $t6
blez	$s5, loop3
addi	$t2, $t6, 0
addi	$t1, $t4, 0
j	loop3
endLoop3:
beq	$t2, $t3,  Return
addi	$t4, $zero, 0
addi	$s6, $zero, 1
sll	$t7, $t1, 0x2
add	$t7, $a2, $t7
sw	$s6, 0($t7)

loop4:
addi	$t4, $t4, 1
sub	$s5, $s0, $t4
blez	$s5, loop2
sll	$t5, $t4, 0x2
add	$t8, $t5, $a1
lw	$s7, 0($t8)
add	$t5, $t5, $a2
lw	$t5, 0($t5)
bnez	$t5, loop4
sll	$t6, $t1, 0x3
add	$t6, $t6, $t4
sll	$t6, $t6, 0x2
add	$t6, $a3, $t6
lw	$t6, 0($t6)
beq	$t6, $t3, loop4
add	$t9, $t2, $t6
bne	$s7, $t3, nextJudge2
addi	$s7, $t9, 0
sw	$s7, 0($t8)
j	loop4

nextJudge2:
sub	$s5, $s7, $t9
blez	$s5, loop4
addi	$s7, $t9, 0
sw	$s7, 0($t8)
j	loop4
