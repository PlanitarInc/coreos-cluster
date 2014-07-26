NINSTANCES=3
FLEETCTL_TUNNEL=172.17.8.101
FLEETCTL_HOST_FILE=~/.fleetctl/known_hosts

.PHONY: all run config stop clean

all: run

# Need inject the new user-data on every up
run: config user-data
	vagrant up --provision
	ssh-add ~/.vagrant.d/insecure_private_key
	for i in $$(seq 1 ${NINSTANCES}); do \
	  prefix=`echo ${FLEETCTL_TUNNEL} | sed 's/.$$//'`; \
	  ssh -A -o StrictHostKeyChecking=no \
	    -o UserKnownHostsFile=${FLEETCTL_HOST_FILE} \
	    core@$${prefix}$${i} true; \
	done
	sleep 5s # Wait until the cluster is up
	fleetctl --tunnel=${FLEETCTL_TUNNEL} --strict-host-key-checking=false \
	  --known-hosts-file=${FLEETCTL_HOST_FILE} list-machines
	@echo -e '\n\nUse the following fleetctl settings:'
	@cat .config.sh

stop:
	vagrant halt
	rm discovery-url

clean: 
	vagrant destroy -f
	rm -f user-data discovery-url config.rb ${FLEETCTL_HOST_FILE} .config.sh

config: .config.sh

# If config changes, destroy the cluster
.config.sh: config.rb
	vagrant destroy -f
	rm -f ${FLEETCTL_HOST_FILE}
	echo > $@
	echo 'export FLEETCTL_TUNNEL=${FLEETCTL_TUNNEL}' >> $@
	echo 'export FLEETCTL_HOST_FILE=${FLEETCTL_HOST_FILE}' >> $@

discovery-url:
	curl -s https://discovery.etcd.io/new > $@ || \
	  { rm $@ && false; }

user-data: user-data.sample discovery-url
	sed $< >$@ \
	  -e 's!^\([ ]*\)#\(discovery:\).*$$!\1\2 '$$(cat discovery-url)'!'

config.rb:
	echo > $@
	echo '$$num_instances=${NINSTANCES}' >> $@
	echo '$$update_channel="alpha"' >> $@
	echo '$$enable_serial_logging=false' >> $@
	echo '$$vb_gui=false' >> $@
	echo '$$vb_memory=512' >> $@
	echo '$$vb_cpus=1' >> $@
