FLOYDWARSHALL(1)      User Contributed Perl Documentation     FLOYDWARSHALL(1)



NNAAMMEE
       IMPLEMENTATION OF "SHORTEST PATH Via FLOYD WARSHALL" ALGORITHM IN
       MSEXCEL

SSYYNNOOPPSSIISS
       An input Excel file has to be made. The description of the input file
       is given below.

       The format of the excel_file should be as follows:

       Cells B(i+1), B(i+2), B(i+3) ... should contain the weight of the path
       from vertex "1" to the vertex "i".
       Similarly, cells C(i+1), C(i+2), C(i+3) ... should contain the weight
       of the path from vertex "2" to the vertex "i".
       And so on...The entire graph is represented in this particular manner.
       See the file example_input.xlsx for a sample input.

       The file example_input.xlsx is provided for reference.

       Run the following command in the terminal/command prompt :

           "sh run.sh I<excel_filename> I<number of vertices in the graph>"

       Make sure you have Spreadsheet::XLSX and Excel::Writer::XLSX modules
       installed along with all other dependencies.

DDEESSCCRRIIPPTTIIOONN
       A perl program to generate an excel workbook containing formulae to
       compute the minimum distance and the shortest path as computed by the
       Flyod-Warshall algorithm, given an input graph within predefined
       format.

   UUnnddeerrssttaannddiinngg tthhee oouuttppuutt EExxcceell ffiillee
       A series of squares appears on the right side and on the left side.
       The ith square in this series on each side represents the state of
       weight matrix and that of path matrix after ith iteration in the Flyod-
       Warshall algorithm. The font is italicized and highlighted if it gets
       changed through the ith iteration.

       Finally feel free to change the input and see the values automatically
       recalculate.

AAUUTTHHOORR
       Poojan Mehta, Aashish Goyal



perl v5.14.4                      2014-07-20                  FLOYDWARSHALL(1)
