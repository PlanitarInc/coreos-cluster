NINSTANCES=3
FLEETCTL_TUNNEL=172.17.8.101
FLEETCTL_HOST_FILE=~/.fleetctl/known_hosts

.PHONY: all run config stop clean

all: run

run: config
	vagrant up --provider=virtualbox
	ssh-add ~/.vagrant.d/insecure_private_key
	ssh -A -o StrictHostKeyChecking=no \
	  -o UserKnownHostsFile=${FLEETCTL_HOST_FILE}
	  core@${FLEETCTL_TUNNEL} true
	fleetctl --tunnel=${FLEETCTL_TUNNEL} --strict-host-key-checking=false \
	  --known-hosts-file=${FLEETCTL_HOST_FILE} list-machines
	@echo -e '\n\nUse the following fleetctl settings:'
	@cat .config.sh

stop:
	vagrant halt

clean: 
	vagrant destroy -f
	rm -f user-data discovery-url config.rb ${FLEETCTL_HOST_FILE} .config.sh

config: .config.sh

# If config changes, update the config and destroy the cluster to make sure it
# is recreated with an updated config
.config.sh: config.rb user-data discovery-url
	vagrant destroy -f
	rm -f ${FLEETCTL_TUNNEL}
	echo > $@
	echo 'export FLEETCTL_TUNNEL=${FLEETCTL_TUNNEL}' >> $@
	echo 'export FLEETCTL_HOST_FILE=${FLEETCTL_HOST_FILE}' >> $@

discovery-url:
	curl -s https://discovery.etcd.io/new > $@

user-data: user-data.sample discovery-url
	sed $< >$@ \
	  -e 's!^\([ ]*\)#\(discovery:\).*$$!\1\2 '$$(cat discovery-url)'!'

config.rb:
	echo > $@
	echo '$$num_instances=${NINSTANCES}' >> $@
	echo '$$update_channel="alpha"' >> $@
	echo '$$enable_serial_logging=false' >> $@
	echo '$$vb_gui=false' >> $@
	echo '$$vb_memory=256' >> $@
	echo '$$vb_cpus=1' >> $@

