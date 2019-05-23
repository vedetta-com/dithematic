	# example.com slave
	provide-xfr: 203.0.113.4 tsig.example.com.
	provide-xfr: 2001:0db8::4 tsig.example.com.
	notify: 203.0.113.4 tsig.example.com.
	notify: 2001:0db8::4 tsig.example.com.

