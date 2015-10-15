#!/usr/bin/perl
# If you don't know the code, don't mess around below - BCIV
use POSIX qw(strftime);
use Net::SMTP::SSL;

my $timestamp=strftime "%a %b %e %H:%M:%S %Y", localtime;

my $system; 
my $url; my $from_email; my $from_email_password;
my $helpdeskurl; my $helpdeskcontact; my $helpdeskemail;
my $smtp_server; my $smtp_port;

my $configuration_file='notify.config';

#`rm notify*.log`;

# process:
#
# - this utility iterates through a file that is carat '^' delimited containing:
# 
#	last_name	first_name	email	phone
#
# - an email is sent to each user 
#

# see sample.config and create a configuration file based upon your environment
# update next line to require the configuration file you have configured
# set environment variables

configure($configuration_file);
                    
# iterate through file $file_list

my %h; my $num=1;
open(FIL, '<',$file_list) || die "Cannot read $file_list : $!\n";
while(<FIL>){
  my($lastname,$firstname,$email)=split(/\^/,$_);
  $h{$num}{email}=$email;
  print "$lastname - $firstname - $email\n";
  ++$num;      
}
close(FIL);

# iterate through users returned
foreach $key (sort keys %h) {
  my $email=$h{$key}->{email};

  print "sending email to: $email\n";

  my $subject="$system Domain Migration";
  my $body="You are receiving this message because you have an account with VHA Innovations.<br /><br />As part of a domain migration, you will no longer be able to access the virtual server environment through the Vmware Horizon View Client at https://vm.vacloud.us.<br /> <br />The new location is:  http://vm.vaftl.us<br /><br />Please update your Vmware Horizon View Client to use this new URL.<br /><br />If you have any questions or concerns please do not hesitate to contact the VHA Innovation Help Desk at: <a href=\"$helpdeskurl\">$helpdeskurl</a> or email: <a href=\'mailto:$helpdeskemail?subject=$system Domain Migration\'>$helpdeskemail</a><br /><br />--<br />$helpdeskcontact";
  &send_mail("$email", "$subject", "$body");
}
 
sub send_mail {
  my $to = $_[0];
  my $subject = $_[1];
  my $body = $_[2];
  my $smtp;
  if (not $smtp = Net::SMTP::SSL->new($smtp_server,Port=>$smtp_port,Debug=>1)){
    die "Could not connect to server\n";
  }
  $smtp->auth($from_email, $from_email_password) || die "Authentication failed!\n";
  $smtp->mail($from_email . "\n");
  my @recepients = split(/,/, $to);
  foreach my $recp (@recepients) {
      $smtp->to($recp . "\n");
  }
  $smtp->data();
  $smtp->datasend("MIME-Version: 1.0\n");
  $smtp->datasend("Content-Type: text/html\n");
  $smtp->datasend("From: " . $from_email . "\n");
  $smtp->datasend("To: " . $to . "\n");
  $smtp->datasend("Subject: " . $subject . "\n");
  $smtp->datasend("\n");
  $smtp->datasend($body . "\n");
  $smtp->dataend();
  $smtp->quit;
}

sub configure{
  my $file=$_[0];
  open(IN,$file) or die "Cannot read configuration file, $file : $!";
  while(<IN>){eval $_;} close(IN);
}
