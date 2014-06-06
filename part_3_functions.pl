#use strict;
use Data::Dumper;
my $headers = << 'END_MESSAGE';


	##### EXCEL WRITER PORTION STARTS #####

	use Excel::Writer::XLSX;
	my $file = "output.xlsx";
	my $workbook = Excel::Writer::XLSX->new($file);
	my $worksheet = $workbook->add_worksheet();
END_MESSAGE
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
		return $string;
	}
END_SUB

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
	$filevar = $filevar . $headers . $arrays . "\nmy \$arrays = \$VAR1;\n" . add_excel_funcs($input) . $subroutines;
	$filevar =~ s/^\s+|\s+$//g;

	my $output_file = $ARGV[1];
	open(my $f1h, '>', $output_file) or die "Could not open file '$output_file' $!";
	print $f1h $filevar;
	close $f1h;

	sub find_array{
		# 0th pos constains the name of array
		# 1st pos contains the x pos(or row) of first cell
		# 2nd pos contains the y pos(or col) of first cell
		# 3rd pos contains the number of rows (undef for a 1-d array)
		# 4th pos contains the number of columns
		my $string = (shift @_);my @ans;my $i = 0;my @pos = (0,0);
		while ($string =~ m![\n^][^\S\n\r]*my\s@(\w*);\s*#dim:(\w*)(\[(\d+)\]\[(\d+)\]|\[(\d+)\])!g ){
			if ($1 eq $2){
				$ans[$i][0] = $1; 
				if (!(defined $4)){#if (!($4)){#$4 == null
					#case of 1d array
					$ans[$i][4] = $6; 
					$ans[$i][1] = $pos[0]; $ans[$i][2] = $pos[1];
					@pos = ($pos[0]+3,$pos[1]);
				}
				else{
					#case of 2d array
					$ans[$i][3] = $4;
					$ans[$i][4] = $5;
					$ans[$i][1] = $pos[0]; $ans[$i][2] = $pos[1];
					@pos = ($pos[0]+$ans[$i][3]+2,$pos[1]);
				}
				$i = $i+1;
			}
		}
		return \@ans;
	}
	sub find_array_assignments{
		my $input = (shift @_);my @to_swap;my $i = 0;
		while ($input =~ m!([\n\r^]([^\S\n\r]*)(\$(\w*)(\[[^\n\r\]]*\]|\[[^\n\r\]]*\]\[[^\n\r\]]*\]))[^\S\n\r]*=([^\n\r;]*);)!g){
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
	sub add_excel_funcs{
		my $input = (shift @_);
		my $output = "";
		for (my $j = 0;defined $$input[$j][0];$j++){
			my $name = $$input[$j][0];
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
		return $output . "\n\$workbook->close();\n";
	}

	sub to_excel_pos{#expects a ref to array names and a string to excelify
		my $input = (shift @_);my $string = shift @_;
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
		return $string;
	}
	sub create_bg_arrays{#expects a string to operate on
		my $input = (shift @_);
		$input =~ s![\n^]([^\S\n\r]*)my\s@(\w*);[^\S\n\r]*[\n\r]!\n$1my \@$2;my \@bg_$2;\n!g;
		return $input;
	}
	sub comment_gobbler{#eats up comments from input
		my $string = (shift @_);my $ans;
		while ($string =~ m!([^#\n]*)(#[^\n]*\n)|([^#\n]*\n)!g){
			if (defined $3){$ans = $ans . $3;}
			else{$ans = $ans . $1 . "\n";}
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

