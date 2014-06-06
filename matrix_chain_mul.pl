	use strict;
	use Spreadsheet::XLSX;
	use Excel::Writer::XLSX;


 	my $file = $ARGV[0]; # name of the input excel file to be given as argument
 	my $input = $ARGV[1]; # number of matrices

 	my $excel = Spreadsheet::XLSX -> new ($file); # opens the input file

	if (!defined $excel) {
		die $excel->error(), ".\n";
	}

	my $sheet = $excel -> worksheet(0); # opens the default worksheet
	my $input_text = ($sheet->get_cell('1','0'))->value();

	my @dimensions; # stores the input dimensions 
	for(my $i = 1; $i <= $input + 1; $i++){
		my $cell = $sheet->get_cell(1,$i);
		$dimensions[$i] = $cell->value();
	}


	my $workbook  = Excel::Writer::XLSX->new( $file );# creats a new excel file with name same as that of input file
	my $worksheet = $workbook->add_worksheet();


	my $num = $input; #number of matrices
	my $n = $num+1;
	# assume that B2 to B($n+1) contains the dimensions of the matrices

	# restores the input data in the new file
	$worksheet->write( 'A2', $input_text); 
	for(my $i = 1; $i <= $num + 1; $i++) {
		$worksheet->write_number( '1',$i, $dimensions[$i]);
	}

	# fills in 0 in the diagonal
	for(my $i = 1; $i < $n; $i++) {
	    $worksheet->write_number( $i+3, $i-1, 0 );
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

	# generates and fills in formulae in the upper triangle 
	# fills in the matrices whose product is considered in the lower triangle
	for(my $len=2; $len < $n; $len++){
		for(my $i=1; $i < $n-$len+1; $i++){
			my $j = $i+$len-1;
			my $temp_formula = "=MIN(";
			for(my $k = $i; $k <= $j-1; $k++){
				$temp_formula = $temp_formula.convert($k-1).($i+4)."+".convert($j-1).($k+5)."+(".convert($i)."2*".convert($k+1)."2*".convert($j+1)."2),";
			}
			$temp_formula = substr($temp_formula, 0 ,-1);
			$temp_formula = $temp_formula.")";
			$worksheet->write_formula($i+3,$j-1,$temp_formula);

			my $i1 = ($i + 3) - 4;
			my $j1 = ($j - 1) - 0;
			my $i2 = $j1 + 4;
			my $j2 = $i1 + 0;
			$worksheet->write($i2,$j2,"M$i..M".($i+$len-1));
		}
	}

	# makes the cells square in shape
	for (my $i = 0;$i < $num ;$i++){
		$worksheet->set_row($i+4,40);
	}

$workbook->close();
