[Unit]
Description=IOC: %i 
ConditionHost=icslab-llrf
After=multi-user.target
Requires=multi-user.target

[Service]
User=root
Type=simple

#Run procServ
WorkingDirectory=/epics/base-3.15.5/require/3.0.4/siteApps/sis8300llrf
ExecStart=/usr/bin/procServ \
		-f \
		-L /tmp/log/procServ/out-%i \
		-i ^C^D \
		-c /tmp/run/procServ/%i \
		-n %i \
		2000 \
		/epics/base-3.15.5/require/3.0.4/bin/iocsh.bash \
		/epics/base-3.15.5/require/3.0.4/siteApps/sis8300llrf/llrf.cmd

[Install]
WantedBy=multi-user.target
