#matric chain multiplication perl version.

use Data::Dumper;

	my @p;
	#dim:p[8]
	@p = (3, 12, 3, 4, 15, 5, 7, 8);
	my $n = @p-1;

	my @m;
	#dim:m[7][7]

	for (my $i = 0; $i < $n; $i++){
		for (my $j = 0; $j < $n; $j++){
			$m[$i][$j] = 0;
		}
	}

	for (my $L = 2; $L <= $n; $L++){
		for(my $i = 0; $i < $n-$L+1; $i++){
			my $j = $i+$L-1;
			$m[$i][$j] = 9999999;
			for (my $k = $i; $k <=$j-1; $k++){
				$m[$i][$j] = min($m[$i][$k] + $m[$k+1][$j] + $p[$i]*$p[$k+1]*$p[$j+1],$m[$i][$j]);
			}
		}
	}

	for (my $i = 0; $i < $n; $i++){
		for (my $j = 0; $j < $n; $j++){
			print $m[$i][$j]. " ";
		}
		print "\n";
	}

	sub min {
		my ($min, @vars) = @_;
		for (@vars){
			$min = $_ if $_ < $min;
		}
		return $min;
	}
