
#!/usr/bin/env ruby

require 'rubygems'
require 'net/imap'
require 'pp'

def parse_text(text)
  blk = false
  temp_text = []
  text.each{|x|
    if x.include?("<GMAILFS_DATA>")
      blk = true
    elsif x.include?("<GMAILFS_DATA_END>")
      blk = false
    elsif blk
      temp_text << x
    end
  }
  return temp_text.join("")
end
      
CONFIG = {
  :host     => 'imap.gmail.com',
  :username => '',
  :password => '',
  :port     => 993,
  :ssl      => true
}

imap = Net::IMAP.new( CONFIG[:host], CONFIG[:port], CONFIG[:ssl] )
imap.login( CONFIG[:username], CONFIG[:password] )
imap.select("wallet")

mails = imap.search(['SUBJECT', "[gmailfs]"])

mails.each{|msg_id|
  mail = imap.fetch(msg_id,["ENVELOPE", "UID", "BODY"])[0]

  msg = imap.fetch(msg_id, "(UID RFC822.SIZE ENVELOPE BODY[TEXT])")[0]
  puts parse_text(msg.attr["BODY[TEXT]"])
  

  body = mail.attr["BODY"]
  i = 1
  while body.parts[i] != nil
   cType = body.parts[i].media_type
    cName = body.parts[i].param['NAME']
    i+=1
    # fetch attachment.
    if cType and cName
        attachment = imap.fetch(msg_id, "BODY[#{i}]")[0].attr["BODY[#{i}]"]
        # Save message, BASE64 decoded
        File.new(cName,'wb+').write(attachment.unpack('m'))
    end
  end 
}

imap.logout
