require 'net/smtp'
require 'smtp_tls'

def sendmail_plain(msg, config)
      Net::SMTP.start( config[:smtp_server],
                       config[:smtp_port],
                       config[:smtp_helo],
                       config[:smtp_username],
                       config[:smtp_password],
                       :plain ) { |smtp|
    smtp.send_message( msg, config[:from_address], config[:to_address] )
  }
end

filename = "/tmp/test.txt"
# Read a file and encode it into base64 format
filecontent = File.read(filename)
encodedcontent = [filecontent].pack("m")   # base64

marker = "AUNIQUEMARKER"

body =<<EOF
This is a test email to send an attachement.
EOF

# Define the main headers.

part1 =<<EOF
From: <>
To:  <>
Subject: [gmailfs]
EOF

# Define the attachment section
part3 =<<EOF
Subject: [gmailfs]
Content-Type: multipart/mixed; name=\"#{File.basename(filename)}\"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename="#{File.basename(filename)}"
--#{marker}

#{encodedcontent}
--#{marker}--
EOF

mailtext = part3 # + part3# + part3

# Let's put our code in safe area
begin 
  sendmail_plain(mailtext, {:smtp_server => "smtp.gmail.com", :smtp_port => 587, :smtp_helo => "localhost", :smtp_username => "", :smtp_password => "", :from_address => "", :to_address => ""})
rescue Exception => e
  print "Exception occured: " + e  
end 
