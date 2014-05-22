	use strict;
	use Spreadsheet::XLSX;
	use Excel::Writer::XLSX;
	use Data::Dumper;


 	my $file = $ARGV[0];
 	my $excel = Spreadsheet::XLSX -> new ($file);

	if (!defined $excel) {
	die $excel->error(), ".\n";
	}

	my $sheet = $excel -> worksheet(0);
	my $input_text1 = ($sheet->get_cell('0','0'))->value();
	my $input_text2 = ($sheet->get_cell('1','0'))->value();
	my $input = ($sheet->get_cell('0','1'))->value();#number of matrices
	my @dimensions;
	for(my $i = 1; $i <= $input + 1; $i++){
		my $cell = $sheet->get_cell(1,$i);
		$dimensions[$i] = $cell->value();
	}
#	print Dumper(\@dimensions);

	my $workbook  = Excel::Writer::XLSX->new( $file );#name of the workbook created
#	my $workbook  = Excel::Writer::XLSX->new( 'mat2.xlsx' );#name of the workbook created
	my $worksheet = $workbook->add_worksheet();


	my $num = 5; #number of matrices
	my $n = $num+1;
	# assume that A1 to A($num+1) contains the dimensions of the matrices
	$worksheet->write( 'A1', $input_text1);
	$worksheet->write( 'A2', $input_text2);
	$worksheet->write_number( 'B1', $input);
	for(my $i = 1; $i <= $num + 1; $i++) {
		$worksheet->write_number( '1',$i, $dimensions[$i]);
	}

	for(my $i = 1; $i < $n; $i++) {
	    $worksheet->write_number( $i+3, $i-1, 0 );
	}

	my $a = ord('A');#ascii representation of A. Needed to later switch from numbers to chars
	for(my $len=2; $len < $n; $len++){
		for(my $i=1; $i < $n-$len+1; $i++){
			my $j = $i+$len-1;
			my $temp_formula = "=MIN(";
			for(my $k = $i; $k <= $j-1; $k++){
				$temp_formula = $temp_formula.chr($a+$k-1).($i+4)."+".chr($a+$j-1).($k+5)."+(".chr($a+$i)."2*".chr($a+$k+1)."2*".chr($a+$j+1)."2),";
			}
			$temp_formula = substr($temp_formula, 0 ,-1);
			$temp_formula = $temp_formula.")";
			print $temp_formula . "\n";
			$worksheet->write_formula($i+3,$j-1,$temp_formula);

			my $i1 = ($i + 3) - 4;
			my $j1 = ($j - 1) - 0;
			my $i2 = $j1 + 4;
			my $j2 = $i1 + 0;
			$worksheet->write($i2,$j2,"M$i..M".($i+$len-1));
		}
	}

$workbook->close();
