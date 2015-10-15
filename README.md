# notify
A simple Perl script to send emails to everyone on your list.

# process:

This utility iterates through a file that is carat '^' delimited containing:
 
	last_name^first_name^email^phone

An email is sent to each user that defined by the $body variable.

# configuration
see sample.config and create a configuration file based upon your environment

# email setup
If you are sending from the same machine that is the mail server, it may make more sense 
to simply skip the &sendmail routine altogether and use something like:

```
system("mail -s \"Future Technology Domain Migration\" -r \"noreply\@example.com\" $to < notify.txt");
```

In this example the body of the message would be from a static file (here referenced as 'notify.txt'.

# running notify

```
perl notify.pl
```
