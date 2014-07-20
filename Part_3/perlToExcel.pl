#use strict;
use Data::Dumper;
#headers that need to copied to generated file
my $headers = << 'END_MESSAGE';


	##### EXCEL WRITER PORTION STARTS #####

	use Excel::Writer::XLSX;

	#generate an xlsm file if macros are provided, otherwise an xlsx file
	my $file;
	if ((defined $ARGV[0]) && (defined $ARGV[1])){
		$file = "output.xlsm";
	} else{
		$file = "output.xlsx";
	}
	my $workbook = Excel::Writer::XLSX->new($file);
	my $worksheet = $workbook->add_worksheet();
END_MESSAGE
#subroutines needed by generated file to create excel formulae at runtime
my $subroutines = << 'END_SUB';


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
	sub get_index{#expects a ref to array names and a name whose index is to be found
		my $input = shift (@_);my $name = shift (@_);my $i = 0;
		while(defined $$input[$i][0]){
			if($$input[$i][0] eq $name){return $i;}
			$i = $i+1;
		}
		my $empty_val;
		return $empty_val;#if no match return an empty variable;
	}
		sub to_excel_pos{#expects a ref to array names and a string to excelify
		my $input = (shift @_);my $string = shift @_;
		while($string =~ m!\$(\w*)\[([^\]]+)\]\[([^\]]+)\]\[([^\]]+)\]!g){
			if (defined get_index($input,$1)){
				my $index = get_index($input,$1);
				my $temp = convert($$input[$index][2]+eval($4)).($$input[$index][1]+eval($3) + eval($2)*($$input[$index][3]+3)+1);
				$string =~ s!\$$1\[([^\]]+)\]\[([^\]]+)\]\[([^\]]+)\]!$temp!;
			}
		}
		while($string =~ m!\$(\w*)\[([^\]]+)\]\[([^\]]+)\]!g){
			if (defined get_index($input,$1)){
				my $index = get_index($input,$1);
				my $temp = convert($$input[$index][2]+eval($3)).($$input[$index][1]+eval($2)+1);
				$string =~ s!\$$1\[([^\]]+)\]\[([^\]]+)\]!$temp!;
			}
		}
		while($string =~ m!\$(\w*)\[([^\]]+)\]!g){
			if (defined get_index($input,$1)){
				my $index = get_index($input,$1);
				my $temp = convert($$input[$index][2]+eval($2)).($$input[$index][1]+1);
				$string =~ s!\$$1\[([^\]]+)\]!$temp!;
			}
		}
		# 3rd while loop
		return $string;
	}
END_SUB

	#main script of the program
	my $filename = $ARGV[0];
	my $filevar = "";
	open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
	while (my $row = <$fh>){chomp $row;$filevar = $filevar.$row."\n";}
	close $fh;
	$input = find_array($filevar);
	my $arrays = Dumper($input);
	$filevar = comment_gobbler($filevar);
	$filevar = create_bg_arrays($filevar);
	$filevar = find_array_assignments($filevar);
	$filevar = find_arrayvalue_assignments($filevar);
	$filevar = $filevar . $headers . $arrays . "\nmy \$arrays = \$VAR1;\n" . add_excel_funcs($input) . $subroutines;
	$filevar =~ s/^\s+|\s+$//g;

	my $output_file = $ARGV[1];
	open(my $f1h, '>', $output_file) or die "Could not open file '$output_file' $!";
	print $f1h $filevar;
	close $f1h;
	#script ends

	#this function takes a file as input and then finds the arrays which are declared as per the convention
	#the array name and its dimensions are stored in an array. Also the subroutine determines the starting row and 
	# column of the arrays on the basis of array dimensions and stores them in the array which is finally returned
	sub find_array{
		# 0th pos constains the name of array
		# 1st pos contains the x pos(or row) of first cell
		# 2nd pos contains the y pos(or col) of first cell
		# 3rd pos contains the number of rows (undef for a 1-d array)
		# 4th pos contains the number of columns
		# 5th pos contains the third dimension (only valid for a 3-d array)
		my $string = (shift @_);my @ans;my $i = 0;my @pos = (0,0);
		while ($string =~ m![\n^][^\S\n\r]*my\s@(\w*);\s*#dim:(\w*)(\[(\d+)\]\[(\d+)\]\[(\d+)\]|\[(\d+)\]\[(\d+)\]|\[(\d+)\])!g ){
			if ($1 eq $2){ 
				$ans[$i][0] = $1; 
				if (!(defined $4)){
					if (!(defined $7)){#if (!($4)){#$4 == null
					#case of 1d array
						$ans[$i][4] = $9; 
						$ans[$i][1] = $pos[0]; $ans[$i][2] = $pos[1];
						@pos = ($pos[0]+3,$pos[1]);
					}
					else{
					#case of 2d array
						$ans[$i][3] = $7;
						$ans[$i][4] = $8;
						$ans[$i][1] = $pos[0]; $ans[$i][2] = $pos[1];
						@pos = ($pos[0]+$ans[$i][3]+2,$pos[1]);
					}
				}
				else{
					#case of 3d array
					$ans[$i][3] = $5;
					$ans[$i][4] = $6;
					$ans[$i][5] = $4;
					$ans[$i][1] = $pos[0]; $ans[$i][2] = $pos[1];
					@pos = ($pos[0],$pos[1]+(($ans[$i][4] +3)));

				}	
				$i = $i+1;
			}
		}
		return \@ans;
	}
	
	#this function takes a file as input and locates each array assignment and appends this with an additonal
	#statement to store the stringified version of the assignment in bg_<array_name>, which is an array the program
	#shall use to store excel formulae
	sub find_array_assignments{
		my $input = (shift @_);my @to_swap;my $i = 0;
		while ($input =~ m!([\n\r^]([^\S\n\r]*)(\$(\w*)(\[[^\n\r\]]*\]|\[[^\n\r\]]*\]\[[^\n\r\]]*\]|\[[^\n\r\]]*\]\[[^\n\r\]]*\]\[[^\n\r\]]*\]))[^\S\n\r]*=([^\n\r;]*);)!g){
			# change the regex
			$i = $i+1;
			$to_swap[$i][0] = $1;
			my $string = $1;
			$string = $string . "\n$2\$bg_$4$5 = ";
			my $to_write = quotemeta($4.$5);
			my $temp = $6;
			#swap for input var;
			$temp =~ s!\$(\w*)\[!\\\$$1\[!g;
			$temp =~ s!\\\$($to_write)!\(\$bg_$1\)!g;
			$to_swap[$i][1] = $string . "\"" . $temp . "\";";
		}
		while($i>0){
			$input =~ s!\Q$to_swap[$i][0]!$to_swap[$i][1]!;
			$i = $i-1;
		}
		return $input;
	}
	
	#this function takes a file as input and locates each array assignment and appends this with an additonal
	#statement to store the stringified version of the assignment in bg_<array_name>, which is an array the program
	#shall use to store excel formulae
	sub find_arrayvalue_assignments{
		my $input = (shift @_);my @to_swap;my $i = 0;
		while ($input =~ m!([\n\r^]([^\S\n\r]*)(\@(\w*))[^\S\n\r]*=([^;]*);)!g){
			# change the regex
			$i = $i+1;
			$to_swap[$i][0] = $1;
			my $string = $1;
			$string = $string . "\n$2\@bg_$4 = $5 ;";

			$to_swap[$i][1] = $string ;
		}
		while($i>0){
			$input =~ s!\Q$to_swap[$i][0]!$to_swap[$i][1]!;
			$i = $i-1;
		}
		return $input;
	}
	
	#this function adds loops at the end of the script which make some corrections to the formulae and then write
	#them into the excel sheet
	sub add_excel_funcs{
		my $input = (shift @_);
		my $output = "";
		for (my $j = 0;defined $$input[$j][0];$j++){
			my $name = $$input[$j][0];
			if (!(defined $$input[$j][5])){
				if(!(defined $$input[$j][3])){
					$output = $output . "\n" .
					"	for(my \$i = 0; \$i < \$\$arrays[$j][4];\$i++){" . 
					"\n		\$bg_$name\[\$i\] = to_excel_pos(\$arrays,\$bg_$name\[\$i\]);".
					"\n		\$worksheet->write($$input[$j][1], $$input[$j][2]+\$i,\"=\".\$bg_$name\[\$i\]);".
					"\n	}";
				}
				else{
					$output = $output . "\n" .
					"	for(my \$i = 0; \$i < \$\$arrays[$j][3];\$i++){"."\n".
					"		for(my \$k = 0; \$k < \$\$arrays[$j][4];\$k++){" . 
					"\n			\$bg_$name\[\$i\]\[\$k\] = to_excel_pos(\$arrays,\$bg_$name\[\$i\]\[\$k\]);".
					"\n			\$worksheet->write($$input[$j][1]+\$i, $$input[$j][2]+\$k,\"=\".\$bg_$name\[\$i\]\[\$k\]);".
					"\n		}".
					"\n	}";
				}
			}
			else{
				$output = $output . "\n" .
				"	for(my \$i = 0; \$i < \$\$arrays[$j][5];\$i++){"."\n".
				"		for(my \$j_ = 0; \$j_ < \$\$arrays[$j][3];\$j_++){" . "\n".
				"			for(my \$k = 0; \$k < \$\$arrays[$j][4];\$k++){".
				"\n				\$bg_$name\[\$i\]\[\$j_\]\[\$k\] = to_excel_pos(\$arrays,\$bg_$name\[\$i\]\[\$j_\]\[\$k\]);".
				"\n				\$worksheet->write($$input[$j][1]+\$j_ + \$i * (\$\$arrays[$j][3] + 3), $$input[$j][2]+\$k,\"=\".\$bg_$name\[\$i\]\[\$j_\]\[\$k\]);".
				"\n 		}".
				"\n		}".
				"\n	}";

			}
			# 3rd case (which position to write)
		}
		my $macro_addition = "\n".
			"\$macro = \$ARGV[0];\n".
			"\$macro_handler = \$ARGV[1];\n".
			"if((defined \$macro) && (defined \$macro_handler)){\n".
			"	do \$macro_handler;\n".
			"	add_macro(\$macro, \$workbook, \$worksheet)\n".
			"}\n";
		return $output . $macro_addition ."\n\$workbook->close();\n";
	}

	#the role of this function is to correct the formulae or interpolate the position of cells
	#e.g. "=add($input[2]),$input[5])" -> "=add(A3,A6)"
	sub to_excel_pos{#expects a ref to array names and a string to excelify
		my $input = (shift @_);my $string = shift @_;
		while($string =~ m!\$(\w*)\[([^\]]+)\]\[([^\]]+)\]\[([^\]]+)\]!g){
			if (defined get_index($input,$1)){
				my $index = get_index($input,$1);
				my $temp = convert($$input[$index][2]+eval($4)).($$input[$index][1]+eval($3) + eval($2)*($$input[$index][3]+3)+1);
				$string =~ s!\$$1\[([^\]]+)\]\[([^\]]+)\]\[([^\]]+)\]!$temp!;
			}
		}
		while($string =~ m!\$(\w*)\[([^\]]+)\]\[([^\]]+)\]!g){
			if (defined get_index($input,$1)){
				my $index = get_index($input,$1);
				my $temp = convert($$input[$index][2]+eval($3)).($$input[$index][1]+eval($2)+1);
				$string =~ s!\$$1\[([^\]]+)\]\[([^\]]+)\]!$temp!;
			}
		}
		while($string =~ m!\$(\w*)\[([^\]]+)\]!g){
			if (defined get_index($input,$1)){
				my $index = get_index($input,$1);
				my $temp = convert($$input[$index][2]+eval($2)).($$input[$index][1]+1);
				$string =~ s!\$$1\[([^\]]+)\]!$temp!;
			}
		}
		# 3rd while loop
		return $string;
	}
	
	#takes a file as input. for every array declared in the file, creates a bg_<array_name> array which will store
	#the corresponding excel values
	sub create_bg_arrays{#expects a string to operate on
		my $input = (shift @_);
		$input =~ s![\n^]([^\S\n\r]*)my\s@(\w*);[^\S\n\r]*[\n\r]!\n$1my \@$2;my \@bg_$2;\n!g;
		return $input;
	}
	
	#a simple function to remove comments from input
	sub comment_gobbler{#eats up comments from input
		my $string = (shift @_);my $ans;
		while ($string =~ m!([^#\n]*)(#[^\n]*\n)|([^#\n]*\n)!g){
			if (defined $3){$ans = $ans . $3;}
			else{$ans = $ans . $1 . "\n";}
		}
		return $ans;
	}
	
	#function that gives the index of an array contained in the input program, given the array name and the array 
	#returned by find_arrays
	sub get_index{#expects a ref to array names and a name whose index is to be found
		my $input = shift (@_);my $name = shift (@_);my $i = 0;
		while(defined $$input[$i][0]){
			if($$input[$i][0] eq $name){return $i;}
			$i = $i+1;
		}
		my $empty_val;
		return $empty_val;#if no match return an empty variable;
	}
	
	#converts numbers to column names
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


=pod

=head1 NAME

SCRIPT TO AUGMENT PERL CODE TO GENERATE EXCEL IMPLEMENTATION OF CODE

=head1 SYNOPSIS

This script takes a file as an argument and augments it.

Consider the following example.
	
=over 12

=item C<perl perlToExcel.pl example.pl output.pl>

The script reads in example.pl and generates output.pl as the output. 

=item C<perl output.pl>

Now perl executes output.pl. This generates the output xlsx file which 
contains the formulae implemeting the algorithm.

=back 

The files included with this include floydWarshall.pl, gausElem.pl and matrixChain.pl 
which implement the floyd warshall, gaussain elimination and the matrix chain multiplication 
algorithms repectively. Also provided are the sample outputs that the perlToExcel generates.

Additionally the script also supports adding macros to the generated script so that it 
generates visual effects. This requires an appropriate macro which will vary with the algorithm
and a helper function which specifies where the buttons must be place and how must the macros be
used.

To do so, simply in the second step change run

	"perl output.pl samplemacro.bin macrohelper.pl"

Make sure you have Spreadsheet::XLSX and Excel::Writer::XLSX modules installed as they are required dependencies.

=head1 DESCRIPTION

This perl program is a way to generate excel formulas for algorithms which involve array manipulation.
It finds the sections where the array assignment is done and then converts them such corresponding excel
formulae are stored in an array. These formulae are then written to the excel file.

=head2 Methods

=over 12

=item C<find_array>

This function takes a file as input and then finds the arrays which are declared as per the convention
The array name and its dimensions are stored in an array. Also the subroutine determines the starting row and 
column of the arrays(in the excel sheet) on the basis of array dimensions and stores them in the array 
which is finally returned.
	0th pos constains the name of array
	1st pos contains the x pos(or row) of first cell
	2nd pos contains the y pos(or col) of first cell
	3rd pos contains the number of rows (undef for a 1-d array)
	4th pos contains the number of columns
	5th pos contains the third dimension (only valid for a 3-d array)

=item C<find_array_assignments> 

This function takes a file as input and locates each array assignment and appends this with an additonal
statement to store the stringified version of the assignment in bg_<array_name>, which is an array the program
shall use to store excel formulae

=item C<find_arrayvalue_assignments> 

This function takes a file as input and locates value assignment for each array and adds this with an additonal
statement to assign bg_<array_name> the same values assigned to the respective array.

=item C<add_excel_funcs> 

This function adds loops at the end of the script which makes some corrections to the formulae and then write
them into the excel sheet

=item C<to_excel_pos>

The role of this function is to correct the formulae / interpolate the position of cells
e.g. "=add($input[2]),$input[5])" -> "=add(A3,A6)"

=item C<create_bg_arrays>

Takes a file as input. for every array declared in the file, creates a bg_<array_name> array which will store
the corresponding excel values

=item C<comment_gobbler>

a simple function to remove comments from input

=item C<get_index>

Function that gives the index of an array contained in the input program, given the array name and the array 
returned by find_arrays

=item C<convert>

converts numbers to column names

=back

You may change the dimensions of the arrays and the script will regenerate the excel with the appropriate
formulae

=head1 AUTHOR

=over 5

=item C<Aashish Goyal>

=item C<Poojan Mehta>

=back

=cut
