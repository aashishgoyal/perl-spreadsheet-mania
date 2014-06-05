# 1)Convention=> after declaring array, immediately follow it with a dubious value indicator so that
# its dimensions can be percieved. If no such declaration, it will be considered temporary.
# 2)assume that arrays only have numbers

#	use strict;
	use Data::Dumper;

	my @input;
#dim:input[4]  # to indicate that input is a 1-d array with dimensions 3
	@input = (1,3,4,7);

	my $inp_len = @input;

	my @output;
#dim:output[4][4] #indicates that output is a 2-d array with dimensions 4 x 4
	for(my $i = 0; $i < $inp_len; $i++){
		for(my $j = 0; $j < $inp_len; $j++){
			$output[$i][$j] = $input[$i] * $input[$j];
		}
	}
	print "finished actual prog";
