	# GratisDNS.com slave
	provide-xfr: 91.221.196.0/28 NOKEY
	provide-xfr: 2001:67c:3c0:0010::9 NOKEY
	provide-xfr: 2001:67c:3c0:0010::11 NOKEY
	notify: 91.221.196.11 NOKEY

