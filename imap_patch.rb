--- imap.rb     2007-02-19 02:20:05.000000000 -0800
+++ imap-patched.rb     2007-02-19 02:22:00.000000000 -0800
@@ -2743,6 +2743,10 @@
         when /\A(?:UIDVALIDITY|UIDNEXT|UNSEEN)\z/n
           match(T_SPACE)
           result = ResponseCode.new(name, number)
+        when /\A(?:NOMODSEQ)\z/n
+          # recognize and ignore Cyrus IMAP 2.3.7+ NOMODSEQ
response
+          # reference: http://rubyforge.org/tracker/?func=detail
&atid=1698&aid=7233&group_id=426
+          result = ResponseCode.new(name, nil)
         else
           match(T_SPACE)
           @lex_state = EXPR_CTEXT

