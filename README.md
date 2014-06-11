# Perl-Spreadsheet-Mania

### Part-I : Matrix Chain Multiplication

**A brief decription of the project:**

A perl program to generate an excel workbook containing formulae to compute the minimum number of computations required for multiplying a matrix chain. The algorithm used is the standard algorithm for this problem using dynamic programming. 

**Steps:**

1. Make sure you have Spreadsheet::XLSX and Excel::Writer::XLSX modules installed along with all other dependencies.

2. Run the following command in the terminal/command prompt :
		perl matrix_mul <excel_filename> <number of matrices to be multiplied>
		
3. The format of the excel_file should be as follows:
		Cells B2, B3, B4 ....... should contain the dimensions of the matrices to be multiplied. Here the B(i+1)th, B(i+2)th cell contains the dimensions of the ith matrix.

**Result:**

After the running the command with appropriate input parameters, the input excel_file gets modified and a square filled with data appears.

**Reading the square:**

Pick any square inside this big square. The top right cell of it contains the minumum cost of multiplying the matrices given in the bottom left corner of this smaller square.
		
### Part-II : Floyd-Warshall algorithm

...to be documented

### Part-III : Transforming an input perl script

**Objective:**

To read a perl script that implements the above alogrithms and manipulate them to create excel programs from these.

**Assumptions:**

1. Convention=> after declaring array, immediately follow it with a dubious value indicator so that its dimensions can be percieved. If no such declaration, it will be considered temporary array.
2. Assume program arrays only manipulate numbers

(Assumptions need to be more documented comprehensively)

**There were two approaches to the problem:**

* To build sort of a parser for perl. Here we try to understand the logic of the input program and output a program to generate the corresponding excel file. Such a parser would (of course) implement only a small portion of the program and thereby severly limit the possible programs that can be accepted.
* Another idea which has been tried to be implemented is to understand what the program does in the array assignment stage. A new file containing the previous code is created but with additional code in between and at the ends which handles the generation of the excel formulae.


As of now the second approach has found some success indeed.
It is able to generate the correct output file for some programs. e.g test.pl, matrix.pl

**Instructions to test code:**

1. Ensure that all libraries are installed.
2. Download test.pl/mat.pl and part_3_functions.pl in same dir
3. Run:- perl part_3_funcions.pl <name_of_input_filename> <any_name_output_file_should_have>
4. This creates a file in same dir. Run this to get excel file(and compare its source code).
5. The excel file does not initialize values but formulae in appropriate columns are present.
6. Input values in test.pl/matrix.pl may be changed but the important thing is the size declaration of the arrays in comments, both of which must be changed appropriately.




