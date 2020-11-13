Names: 
	Mina Ashraf Gamil	900182973
	Sherif Hisham Gabr	900183120

Version: V1.0 - MS1 Single-Cycled RISC-V Processor


Assumptions:
	No assumptions were made. Everything was from the manual and can only work the way it is designed.
	

Issues:
	through our testing, which was not very thorough, we didn't discover any issues in our processor implementation. 
	this statement still needs further validation as we continue with our testing in the next phase. 

Need To-Do:

	we still need to support ECALL, FENCE, BREAK.
	we still need to test the rest of the instructions that are untested.


Instruction Summary:

  Instructions	  |	  Implemented	  |	      Tested Successful		

	LUI			yes			
	AUIPC			yes			
	JAL 			yes			
	JALR			yes			
	BEQ			yes			yes
	BNE			yes			yes
	BLT			yes			yes
	BGE			yes			yes
	BLTU			yes			yes
	BGEU			yes			yes
	LB			yes			
	LH			yes			
	LW			yes			
	LBU			yes			
	LHU 			yes				
	SB 			yes			
	SH 			yes			
	SW			yes			
	ADDI			yes			yes		
	STLI			yes			yes
	SLTIU			yes			yes	
	XORI			yes			yes
	ORI			yes			yes
	ANDI			yes			yes
	SLLI			yes			yes
	SRLI			yes			yes
	SRAI			yes			yes
	ADD			yes			yes
	SUB			yes			yes
	SLL			yes			yes
	SLT			yes			yes	
	SLTU 			yes			yes	
	XOR			yes			yes
	SRL			yes			yes
	SRA			yes			yes
	OR			yes			yes
	AND			yes			yes
	FENCE			yes
	ECALL			yes
	EBREAK			yes





Last Updated: 13 November 2020 - 4:27pm




