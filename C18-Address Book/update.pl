#! /usr/bin/perl
use Cwd;
use File::Path;

my $sourcedir = "/Users/ericasadun/Desktop/Work/SDKStuff/11Development/Canon/ABContactsHelper/";

opendir(my $dirh, cwd()) or die "Could not opendir($dir) - $!";
foreach my $item (grep { /-/ } readdir($dirh))
{
    docopy("ABContact.h", $item);
    docopy("ABContact.m", $item);
    docopy("ABGroup.h", $item);
    docopy("ABGroup.m", $item);
    docopy("ABContactsHelper.h", $item);
    docopy("ABContactsHelper.m", $item);
}

sub docopy
{
    (my $fname, $subdir) = @_;

    my $source = $sourcedir . $fname;
    $source =~ s/ /\\ /g;
    # print "Copying from $source \n";

    my $file = cwd . "/" . $subdir . "/" . $fname;
    $file =~ s/ /\\ /g;
    # print "Copying to $file \n";

    `cp $source $file`;
}