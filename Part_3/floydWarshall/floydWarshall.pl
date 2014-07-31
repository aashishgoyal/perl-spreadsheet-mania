#floyd warshall algorithm: perl version.

use Data::Dumper;

	my @p; #dim:p[3][3]
	@p = ([0,1,2],
			[5,0,3],
			[1,2,0]);	
	my $n = 3;

	my @m;
	#dim:m[4][3][3]
	my @path;
	#dim:path[4][3][3]

	for (my $i = 0; $i < $n; $i++){
		for (my $j = 0; $j < $n; $j++){
			$m[0][$i][$j] = $p[$i][$j];
			$path[0][$i][$j] = -1;
		}
	}


	for(my $i=1; $i < $n+1 ; $i++){
   	 for(my $j=0; $j < $n; $j++){
        for(my $k=0; $k < $n; $k++){
           $m[$i][$j][$k] = min($m[$i-1][$j][$k], $m[$i-1][$j][$i-1] + $m[$i-1][$i-1][$k] ) ;
           $path[$i][$j][$k] = IF($m[$i-1][$j][$k] > ($m[$i-1][$j][$i-1] + $m[$i-1][$i-1][$k]),$i,$path[$i-1][$j][$k]);
        }
    }
}

for(my $i=0; $i < $n+1 ; $i++){
   	 for(my $j=0; $j < $n; $j++){
        for(my $k=0; $k < $n; $k++){
           print $m[$i][$j][$k]." ";
           
        }
        print "\n";
    }
    print "\n\n ";
}	

	sub min {
		my ($min, @vars) = @_;
		for (@vars){
			$min = $_ if $_ < $min;
		}
		return $min;
	}

	sub IF {
		my ($c,$e1,$e2) = @_;
		if ($c) {
			return $e1;
		}
		else {
			$e2;
		}
	}
