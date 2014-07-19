use Data::Dumper;
	
	#the algorithm ahead is essentially designed for square matrix
	my @p; #dim:p[5][5]
	my @p = ([11,11,12,6,8],
			[5,14,13,32,4],
			[8,6,7,12,19],
			[13,7,13,5,24],
			[11,22,13,9,8]);	

	my @q; #dim:q[5]
	my @q = (4,7,5,8,3);

	#must be same as the dimensions of the square matrix
	my $n = 5;

	my @a; #dim:a[5][5][5]
	my @l;

	#b is as [5][1] so that it appears as a column matrix
	my @b; #dim:b[5][5][1]

	for (my $i = 0; $i < $n; $i++){
		for (my $j = 0; $j < $n; $j++){
			$a[0][$i][$j] = $p[$i][$j];
		}
		$b[0][$i][0] = $q[$i];
	}

#for(my $i=1; $i < $n ; $i++){
#	my $temp = $a[$i-1][$i-1][$i-1];
#	for(my $j=0; $j < $n; $j++){
#		my $temp2 = IF(($temp == 0), 0, $a[$i-1][$j][$i-1] / $temp);
#		my $temp2 = IF(OR($temp > 0, $temp < 0), $a[$i-1][$j][$i-1] / $temp, 0);
#		for(my $k=0; $k < $n; $k++){
#			$a[$i][$j][$k] = IF($j < $i, $a[$i-1][$j][$k], $a[$i-1][$j][$k] - ($temp2 * $a[$i-1][$i-1][$k]));
#		}
#		$b[$i][$j][0] = IF($j < $i, $b[$i-1][$j][0], $b[$i-1][$j][0] - ($temp2 * $b[$i-1][$i-1][0]));
#	}
#}


###
# The above portion runs correct. The lower code is the same, except it does not use local variables.
###

for(my $i=1; $i < $n ; $i++){
#	my $temp = $a[$i-1][$i-1][$i-1];
	for(my $j=0; $j < $n; $j++){
#		my $temp2 = IF(($temp == 0), 0, $a[$i-1][$j][$i-1] / $temp);
#		my $temp2 = IF(OR($a[$i-1][$i-1][$i-1] > 0, $a[$i-1][$i-1][$i-1] < 0), $a[$i-1][$j][$i-1] / $a[$i-1][$i-1][$i-1], 0);
		for(my $k=0; $k < $n; $k++){
			$a[$i][$j][$k] = IF($j < $i, $a[$i-1][$j][$k], $a[$i-1][$j][$k] - (IF(OR($a[$i-1][$i-1][$i-1] > 0, $a[$i-1][$i-1][$i-1] < 0), $a[$i-1][$j][$i-1] / $a[$i-1][$i-1][$i-1], 0) * $a[$i-1][$i-1][$k]));
		}
		$b[$i][$j][0] = IF($j < $i, $b[$i-1][$j][0], $b[$i-1][$j][0] - (IF(OR($a[$i-1][$i-1][$i-1] > 0, $a[$i-1][$i-1][$i-1] < 0), $a[$i-1][$j][$i-1] / $a[$i-1][$i-1][$i-1], 0) * $b[$i-1][$i-1][0]));
	}
}


for(my $i=0; $i < $n ; $i++){
   	 for(my $j=0; $j < $n; $j++){
        for(my $k=0; $k < $n; $k++){
           print $a[$i][$j][$k]." "; 
        }
        print "\n";
    }
    print "\n\n ";
}	

for(my $i=0; $i < $n ; $i++){
   	 for(my $j=0; $j < $n; $j++){
        for(my $k=0; $k < 1; $k++){
           print $b[$i][$j][$k]." ";
           
        }
        print "\n";
    }
    print "\n\n ";
}	

	sub IF {
		my ($c,$e1,$e2) = @_;
		if ($c) {
			return $e1;
		}
		else {
			return $e2;
		}
	}
	sub OR{
		my($a,$b) = @_;
		return ($a or $b);	
	}