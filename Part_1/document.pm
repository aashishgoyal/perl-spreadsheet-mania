MATRIXCHAINMULT(1)    User Contributed Perl Documentation   MATRIXCHAINMULT(1)



NNAAMMEE
       IMPLEMENTATION OF "MINIMUM COST FOR MATRIX CHAIN MULTIPLICATION"
       ALGORITHM IN MSEXCEL

SSYYNNOOPPSSIISS
       An input Excel file has to be made. The description of the input file
       is given below.

       The format of the excel_file should be as follows:

       Cells B2, B3, B4 ....... should contain the dimensions of the matrices
       to be multiplied.
       Here the B(i+1)th, B(i+2)th cell contains the dimensions of the ith
       matrix.

       The file example_input.xlsx is provided for reference.

       Run the following command in the terminal/command prompt :

               "sh run.sh I<excel_filename> I<number of matrices to be multiplied>"

       Make sure you have Spreadsheet::XLSX and Excel::Writer::XLSX modules
       installed along with all other dependencies.

DDEESSCCRRIIPPTTIIOONN
       This is a perl program to generate an excel workbook containing
       formulae to compute the minimum number of computations required for
       multiplying a matrix chain.  The algorithm used is the commonly used
       algorithm based on dynamic programming.

   UUnnddeerrssttaannddiinngg tthhee oouuttppuutt EExxcceell ffiillee
       After the running the command with appropriate input parameters, the
       input excel_file gets modified and a square filled with data appears.

       Pick any square inside this big square.
       Each cell in the lower half of the big square represents a sub-chain of
       the matrix chain.
       The minimum computations required for this sub-chain is reflected in
       the corresponding cell(take mirror image about diagonal) in the upper
       half.

       Finally feel free to change the input and see the values automatically
       recalculate.

AAUUTTHHOORR
       Poojan Mehta, Aashish Goyal



perl v5.14.4                      2014-07-17                MATRIXCHAINMULT(1)
