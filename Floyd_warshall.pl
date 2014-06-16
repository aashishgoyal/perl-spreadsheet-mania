use strict;
use Spreadsheet::XLSX;
use Excel::Writer::XLSX;


my $file = $ARGV[0]; # name of the input excel file to be given as argument
my $max_vertex = $ARGV[1]; # maximum value a vertex can have in the graph, vertices can have values = 1,2,3.......

my $excel = Spreadsheet::XLSX -> new ($file); # opens the input file

if (!defined $excel) {
    die $excel->error(), ".\n";
}

my $sheet = $excel -> worksheet(0); # opens the default worksheet

my @vertices; # stores the input vertices
for(my $i = 1; $i <= $max_vertex ; $i++){
    my $cell = $sheet->get_cell(0,$i);
    $vertices[$i-1] = $cell->value();
}

my @W; # stores the weights btw each nodes

# populate the initial weight array (Use a number much larger than normal weights to represent infinity for non-existant edges)
for(my $i = 0; $i < $max_vertex; $i++){
    my @temp;
    for(my $j = 0; $j < $max_vertex; $j++){
        $temp[$j] = ($sheet->get_cell($i+1,$j+1))->value;
    }
    @{$W[$i]} = @temp;
}
my @P; # stores the shortest path info, all entries intiallized to -1.
for(my $i = 0; $i < $max_vertex; $i++){
    my @temp;
    for(my $j = 0; $j < $max_vertex; $j++){
        $temp[$j] = -1
    }
    @{$P[$i]} = @temp;
}


print "@$_\n" for @W;
my $workbook = Excel::Writer::XLSX->new( $file );# creats a new excel file with name same as that of input file
my $worksheet = $workbook->add_worksheet();



# restores the input data in the new file with some display changes
my $format = $workbook->add_format();
$format->set_bold();

my $format_color1 = $workbook->add_format(fg_color => 'pink', border   => 1,align => 'center', size => 15);
my $format_color2 = $workbook->add_format(fg_color => 'lime',border   => 1, align => 'center', size => 15);
my $change_format = $workbook->add_format(bold => 1, italic => 1, color    => '#9C0006');


for(my $offset=0; $offset <= $max_vertex; $offset++){
    for(my $i = 1; $i <= $max_vertex; $i++) {
        $worksheet->write_number( $offset*($max_vertex + 3),$i, $vertices[$i-1],$format);
        $worksheet->write_number( $i + ($offset*($max_vertex + 3)),'0', $vertices[$i-1],$format);
        $worksheet->write_number( $offset*($max_vertex + 3),$i + $max_vertex + 5, $vertices[$i-1],$format);
        $worksheet->write_number( $i + ($offset*($max_vertex + 3)),$max_vertex + 5, $vertices[$i-1],$format);
    }
    if ($offset==0){
        $worksheet->write($offset*($max_vertex + 3) + int($max_vertex/2),
                        $max_vertex + 3,
                        "Original state");
    }
    else {
        $worksheet->write($offset*($max_vertex + 3) + int($max_vertex/2),
                        $max_vertex + 3,
                        $offset."th iteration");
    }
    $worksheet->write($offset*($max_vertex + 3),0,"Weight",$format);
    $worksheet->write($offset*($max_vertex + 3), $max_vertex + 5,"Path",$format);

}

for(my $i = 0; $i < $max_vertex; $i++){
    my @temp =  @{$W[$i]};
    for(my $j = 0; $j < $max_vertex; $j++){
        $worksheet->write_number($i+1,$j+1,$temp[$j],$format_color1);
        $worksheet->write_number($i+1,$j+1 + $max_vertex + 5,-1,$format_color2);
    }
    $worksheet->set_row($i + 1,43.5);
}



my $a = ord('A');#ascii representation of A. Needed to later switch from numbers to chars
sub convert{
    my $a = ord('A');
    my $num = (shift @_);
    my $ans = '';
    if ($num<0) {return ''};
    if ($num==0){
        return 'A';
    }
    else{
        return convert(int ($num / 26) -1).chr(($num%26)+$a);
    }
return $ans;
}

my $offset  = 1; # keeps the offset which helps to print the new matrix formed in a step.

# generates and fills in formulae in 2-D matrices created after each step in the loop
for(my $i=0; $i < $max_vertex; $i++){
    for(my $j=0; $j < $max_vertex; $j++){
        for(my $k=0; $k < $max_vertex; $k++){
            my $temp_formula1 = "=MIN(". convert($k +1).($j + (($offset-1)*($max_vertex + 3)) +2 ) .
                                ",". convert($i +1).($j + (($offset-1)*($max_vertex + 3)) +2 ).
                                "+".convert($k +1).($i + (($offset-1)*($max_vertex + 3)) +2 ).")";
            my $temp_formula2 = "=IF(". convert($k + 1).($j+ (($offset-1)*($max_vertex + 3)) + 2).">".
                                 convert($i +1).($j + (($offset-1)*($max_vertex + 3)) +2 ) .
                                "+".convert($k +1).($i + (($offset-1)*($max_vertex + 3)) +2 ).",".
                                ($i+1).",".convert($k + 1 + $max_vertex + 5).($j + (($offset-1)*($max_vertex + 3)) +2 ) .")";

            if ($k != $j){
                $worksheet->write_formula($j+ ($offset*($max_vertex + 3)) + 1,$k + 1,$temp_formula1,$format_color1);
                $worksheet->write_formula($j+ ($offset*($max_vertex + 3)) + 1,$k + 1 + $max_vertex + 5,$temp_formula2,$format_color2);
            }
            else {
                $worksheet->write_number($j+ ($offset*($max_vertex + 3)) + 1,$k + 1,0,$format_color1);
                $worksheet->write_number($j+ ($offset*($max_vertex + 3)) + 1,$k + 1 + $max_vertex + 5,-1,$format_color2);
            }
                $worksheet->conditional_formatting(convert($k + 1).($j+ ($offset*($max_vertex + 3)) + 2),
                {
                    type => 'cell',
                    criteria => '<>',
                    value => '$'.convert($k+1).'$'.($j + (($offset-1)*($max_vertex + 3)) +2 ),
                    format => $change_format
                }
                );
        }
        $worksheet->set_row($j+ ($offset*($max_vertex + 3)) + 1,43.5);
    }
    $offset++;
}

$workbook->close();
