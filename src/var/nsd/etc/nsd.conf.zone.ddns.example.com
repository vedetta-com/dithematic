# nsd-checkconf /var/nsd/etc/nsd.conf

zone:
	name: "ddns.example.com."
	zonefile: "slave/ddns.example.com.zone"
	notify-retry: 2
	#
	# as a slave
	#
	# Super Slave
#	include: /var/nsd/etc/nsd.conf.slave.PowerDNS
	# Super Master(s)
#	include: /var/nsd/etc/nsd.conf.master.example.com
	#
	# or a master with slave(s)
	#
	# Super Master
	include: /var/nsd/etc/nsd.conf.master.PowerDNS
	# Super Slave(s)
	include: /var/nsd/etc/nsd.conf.slave.example.com
	# Free Slave(s)
#	include: /var/nsd/etc/nsd.conf.slave.FreeDNS.afraid.org
#	include: /var/nsd/etc/nsd.conf.slave.GratisDNS.com
#	include: /var/nsd/etc/nsd.conf.slave.HE.net
#	include: /var/nsd/etc/nsd.conf.slave.Puck.nether.net
#	include: /var/nsd/etc/nsd.conf.slave.1984.is
