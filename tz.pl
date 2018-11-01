#!/usr/bin/perl

use strict;
use warnings;
# use Data::Dumper;
$ENV{'DOCKER'} = 1;

print "Content-type: application/json\n\n";

# get URL parameters (could be GET or POST) and put them into hash %PAR
my ($buffer, @pairs, $pair, $name, $value, %PAR);

if (exists $ENV{'REQUEST_METHOD'}) {
  $ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;

  if ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
  } else {
    $buffer = $ENV{'QUERY_STRING'};
  }
# Split information into name/value pairs
  @pairs = split(/&/, $buffer);
  foreach $pair (@pairs) {
    ($name, $value) = split(/=/, $pair);
    $value =~ tr/+/ /;
    $value =~ s/%(..)/pack("C", hex($1))/eg;
    $PAR{$name} = $value;
  }
}

if (exists $PAR{cmd} && $PAR{cmd} eq "set") {   ### remove selected connection
  my $tz = $PAR{tz};
  if ($tz) {
    # my $call = "PER5LIB=$perl5lib; $perl $vmwlibdir/connect.pl --credstore $credstore --server $server --username $username --verbose";
    my $call = "sudo /usr/bin/timedatectl set-timezone $tz 2>&1";
    if (exists $ENV{'DOCKER'}) {
      $call = "sudo echo $tz > /etc/timezone; sudo /usr/sbin/dpkg-reconfigure -f noninteractive tzdata 2>&1";
    }
    my $conn = `$call`;
    if ( $? == -1 ) {
      &result(0, "command failed: $!");
    } elsif ( $? == 0 ) {
  my $conn;
      if (exists $ENV{'DOCKER'}) {
        $conn = `sudo /usr/sbin/dpkg-reconfigure -f noninteractive tzdata 2>&1`;
      } else {
	$conn = `/usr/bin/timedatectl 2>&1`;
      }
      chomp $conn;
      if (exists $ENV{'DOCKER'}) {
        $conn =~ /zone:\s+'(.*\/[^']*)'/gm;
        &result(1, "$conn", $1);
      } else {
        $conn =~ /zone: (.*\/[^\s]*)/;
        &result(1, "$conn", $1);
      }
    } else {
      my $arg = sprintf("command exited with value %d", $? >> 8);
      &result(0, "$arg\n$conn");
    }
  } else {
    &result(0, "You have to specify timezone!");
  }
} else {  ### Get actual timezone
  my $conn;
  if (exists $ENV{'DOCKER'}) {
    $conn = `sudo /usr/sbin/dpkg-reconfigure -f noninteractive tzdata 2>&1`;
  } else {
    $conn = `/usr/bin/timedatectl 2>&1`;
  }
  if ( $? == -1 ) {
    &result(0, "command failed: $!\n$conn");
  } elsif( $? == 0 ) {
    chomp $conn;
    if (exists $ENV{'DOCKER'}) {
      $conn =~ /zone:\s+'(.*\/[^']*)'/;
      &result(1, "$conn", $1);
    } else {
      $conn =~ /zone: (.*\/[^\s]*)/;
      &result(1, "$conn", $1);
    }
  } else {
    my $arg = sprintf("command exited with value %d", $? >> 8);
    &result(0, "$arg\n$conn");
  }
}

sub result {
  my ($status, $msg, $currtz) = @_;
  $msg =~ s/\n/\\n/g;
  $msg =~ s/\\:/\\\\:/g;
  $status = ($status) ? "true" : "false";
  print "{ \"success\": $status, \"fullReport\" : \"$msg\", \"currentTZ\" : \"$currtz\"}";
}
