use strict;
use warnings;
use Excel::Writer::XLSX;

sub add_macro{
	my $macro = shift(@_);
	my $workbook = shift(@_);
	my $worksheet = shift(@_);

	$workbook->add_vba_project( './'.$macro );

	$worksheet->insert_button(
	    'D2',
	    {
	        macro   => 'Button1_Click',
	        caption => 'Refresh',
	        width   => 80,
	        height  => 30
	    }
	);

}