	# example.com master
	request-xfr: AXFR 203.0.113.3 tsig.example.com.
	request-xfr: AXFR 2001:0db8::3 tsig.example.com.
	allow-notify: 203.0.113.3 tsig.example.com.
	allow-notify: 2001:0db8::3 tsig.example.com.

