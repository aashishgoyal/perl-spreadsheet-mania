PERLTOEXCEL2(1)       User Contributed Perl Documentation      PERLTOEXCEL2(1)



NNAAMMEE
       SCRIPT TO AUGMENT PERL CODE TO GENERATE EXCEL IMPLEMENTATION OF CODE

SSYYNNOOPPSSIISS
       This script takes a file as an argument and augments it.

       Consider the following example.

       "perl perlToExcel.pl example.pl output.pl"
                   The script reads in example.pl and generates output.pl as
                   the output.

       "perl output.pl"
                   Now perl executes output.pl. This generates the output xlsx
                   file which contains the formulae implemeting the algorithm.

       The files included with this include floydWarshall.pl, gausElem.pl and
       matrixChain.pl which implement the floyd warshall, gaussain elimination
       and the matrix chain multiplication algorithms repectively. Also
       provided are the sample outputs that the perlToExcel generates.

       Additionally the script also supports adding macros to the generated
       script so that it generates visual effects. This requires an
       appropriate macro which will vary with the algorithm and a helper
       function which specifies where the buttons must be place and how must
       the macros be used.

       To do so, simply in the second step change run

               "perl output.pl samplemacro.bin macrohelper.pl"

       Make sure you have Spreadsheet::XLSX and Excel::Writer::XLSX modules
       installed as they are required dependencies.

DDEESSCCRRIIPPTTIIOONN
       This perl program is a way to generate excel formulas for algorithms
       which involve array manipulation.  It finds the sections where the
       array assignment is done and then converts them such corresponding
       excel formulae are stored in an array. These formulae are then written
       to the excel file.

   MMeetthhooddss
       "find_array"
                   This function takes a file as input and then finds the
                   arrays which are declared as per the convention The array
                   name and its dimensions are stored in an array. Also the
                   subroutine determines the starting row and column of the
                   arrays(in the excel sheet) on the basis of array dimensions
                   and stores them in the array which is finally returned.
                        0th pos constains the name of array      1st pos
                   contains the x pos(or row) of first cell      2nd pos
                   contains the y pos(or col) of first cell      3rd pos
                   contains the number of rows (undef for a 1-d array)
                        4th pos contains the number of columns      5th pos
                   contains the third dimension (only valid for a 3-d array)

       "find_array_assignments"
                   This function takes a file as input and locates each array
                   assignment and appends this with an additonal statement to
                   store the stringified version of the assignment in
                   bg_<array_name>, which is an array the program shall use to
                   store excel formulae

       "find_arrayvalue_assignments"
                   This function takes a file as input and locates value
                   assignment for each array and adds this with an additonal
                   statement to assign bg_<array_name> the same values
                   assigned to the respective array.

       "add_excel_funcs"
                   This function adds loops at the end of the script which
                   makes some corrections to the formulae and then write them
                   into the excel sheet

       "to_excel_pos"
                   The role of this function is to correct the formulae /
                   interpolate the position of cells e.g.
                   "=add($input[2]),$input[5])" -> "=add(A3,A6)"

       "create_bg_arrays"
                   Takes a file as input. for every array declared in the
                   file, creates a bg_<array_name> array which will store the
                   corresponding excel values

       "comment_gobbler"
                   a simple function to remove comments from input

       "get_index" Function that gives the index of an array contained in the
                   input program, given the array name and the array returned
                   by find_arrays

       "convert"   converts numbers to column names

       You may change the dimensions of the arrays and the script will
       regenerate the excel with the appropriate formulae

AAUUTTHHOORR
       "Aashish Goyal"
       "Poojan Mehta"



perl v5.14.4                      2014-07-20                   PERLTOEXCEL2(1)
