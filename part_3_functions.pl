	use strict;
	use Data::Dumper;

#a function which scans a string and finds all arrays declared according to the conventions adopted. It returns a
#datastructure which holds the array name its size, and also position to be stored in excel sheet.
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
				if (!($4)){#if ($4 == null){
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
		return @ans;
	}

#for every array in memory create a bg_array to store formulae in them
	sub create_bg_arrays{
		my $input = (shift @_);
		$input =~ s![\n^]([^\S\n\r]*)my\s@(\w*);[^\S\n\r]*[\n\r]!\n$1my \@$2;my \@bg_$2;\n!g;
		return $input;
	}

#this function simply gobbles up comments from a string.
	sub comment_gobbler{#eats up comments from input
		my $string = (shift @_);my $ans;
		while ($string =~ m!([^#\n]*)(#[^\n]*\n)|([^#\n]*\n)!g){
			if ($3){$ans = $ans . $3;}
			else{$ans = $ans . $1 . "\n";}
		}
		return $ans;
	}
