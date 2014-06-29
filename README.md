# Perl-Spreadsheet-Mania

### Part-I : Matrix Chain Multiplication

**A brief decription of the project:**

A perl program to generate an excel workbook containing formulae to compute the minimum number of computations required for multiplying a matrix chain. The algorithm used is the commonly used algorithm based on dynamic programming. 

**Steps:**

1. Make sure you have Spreadsheet::XLSX and Excel::Writer::XLSX modules installed along with all other dependencies.

2. Run the following command in the terminal/command prompt :
		`perl matrixChainMult.pl <excel_filename> <number of matrices to be multiplied>`
		
3. The format of the excel_file should be as follows:
		Cells B2, B3, B4 ....... should contain the dimensions of the matrices to be multiplied. Here the B(i+1)th, B(i+2)th cell contains the dimensions of the ith matrix. The file example_input.xlsx is provided for reference.

**Result:**

After the running the command with appropriate input parameters, the input excel_file gets modified and a square filled with data appears.

**Reading the square:**

Pick any square inside this big square. Each cell in the lower half of the big square represents a sub-chain of the matrix chain. The minimum computations required for this sub-chain is reflected in the corresponding cell(take mirror image about diagonal) in the upper half. Finally feel free to change the input and see the values automatically recalculate. 

### Part-II : Floyd-Warshall algorithm

**A brief decription of the project:**

A perl program to generate an excel workbook containing formulae to compute the minimum distance and the shortest path as computed by the Flyod-Warshall algorithm, given an input graph within predefined format.

**Steps:**

1. Make sure you have Spreadsheet::XLSX and Excel::Writer::XLSX modules installed along with all other dependencies.

2. Run the following command in the terminal/command prompt :
		`perl floydWarshall.pl <excel_filename> <number of vertices in the graph>`

3. The format of the excel_file should be as follows:
		Cells B(i+1), B(i+2), B(i+3) ... should contain the weight of the path from vertex "1" to the vertex "i". Similarly, cells C(i+1), C(i+2), C(i+3) ... should contain the weight of the path from vertex "2" to the vertex "i". And so on...The entire graph is represented in this particular manner. See the file example_input.xlsx for a sample input.

**Result:**

After the running the command with appropriate input parameters, the input excel_file gets modified.

**Reading the output file:**

A series of squares appears on the right side and on the left side. The ith square in this series on each side represents the state of weight matrix and that of path matrix after ith iteration in the Flyod-Warshall algorithm. The font is italicized and highlighted if it gets changed through the ith iteration. 

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

-We finally decided to go ahead with the second idea.

**Instructions to test code:**

1. Ensure that all libraries(discussed in Part_I) are installed.
2. Run:- `perl perlToExcel.pl <name of input filename> <any name output script should have>`.
e.g. `perl perlToExcel.pl matrixChain.pl output.pl`
3. This creates a perl script in the same directory. (Compare the source code of this script with the orginal input perl script to understand what `perlToExcel.pl` actually did.)
4. Run this script to get the excel file.e.g. `perl output.pl`. Alternately, in order to include the appropriate macros also provide the macro file and the macro_helper script. e.g. `perl output.pl  matrixChainMacro.bin matrixChainMacroHelper.pl`.
5. The name of excel file is hard-coded for now (`output.xlsx`/`output.xlsm`). It does not contain initialized values but formulae in appropriate columns are present.
6. Input values in `matrixChain.pl`/`floydWarshall.pl` may be changed but the important thing is the size declaration of the arrays in comments, which must be changed appropriately.
