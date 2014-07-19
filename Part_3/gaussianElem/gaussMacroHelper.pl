use strict;
use warnings;
use Excel::Writer::XLSX;

sub add_macro{
	my $macro = shift(@_);
	my $workbook = shift(@_);
	my $worksheet = shift(@_);

	my $worksheet2 = $workbook->add_worksheet();

	$workbook->add_vba_project( './' . $macro );

	$worksheet2->insert_button(
	    'A4',
	    {
	        macro   => 'Prev',
	        caption => 'Prev',
	        width   => 80,
	        height  => 40
	    }
	);

	$worksheet2->insert_button(
	    'A6',
	    {
	        macro   => 'Refresh',
	        caption => 'Refresh',
	        width   => 80,
	        height  => 40
	    }
	);

	$worksheet2->insert_button(
	    'A8',
	    {
	        macro   => 'Ahead',
	        caption => 'Next',
	        width   => 80,
	        height  => 40
	    }
	);
}