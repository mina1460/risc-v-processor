
#SLT instructions (with hazards)
addi 	x1, x0, 1	#x1 = 00001 => 1
slti	x9, x1, 1 	#x9 = 00000 => 0					(forwarding)

addi	x2, x0, -2	#x2 = 11111111_11111111_11111111_11111110 => -2	
slt 	x8, x2, x0	#x8 = 00000000_00000000_00000000_00000001 => 1		(forwarding)
sltu	x7, x2, x0	#x7 = 00000000_00000000_00000000_00000000 => 0	

addi	x3, x0, -4	#x3 = 11111111_11111111_11111111_11111100 => -4
sltiu	x6, x3, 4	#x6 = 00000000_00000000_00000000_00000000 => 0		(forwarding)

ecall

#FINAL VALUES
#	x1	---> 1
#	x2	---> -2
#	x3	---> -4
#	x6	---> 0
#	x7	---> 0
#	x8	---> 1
#	x9	---> 0
