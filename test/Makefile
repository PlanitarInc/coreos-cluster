.PHONY: test test-sanity test-general test-skydns test-monitord test-graphite \
  test-riemann

test: test-sanity test-general test-skydns test-monitord test-graphite \
  test-riemann

test-sanity:
	  ../script/run-test.sh success.test.service
	  ../script/run-test.sh success.test.service success
	! ../script/run-test.sh success.test.service failure
	! ../script/run-test.sh success.test.service timeout
	! ../script/run-test.sh failure.test.service
	! ../script/run-test.sh failure.test.service success
	  ../script/run-test.sh failure.test.service failure
	! ../script/run-test.sh failure.test.service timeout
	! ../script/run-test.sh timeout.test.service
	! ../script/run-test.sh timeout.test.service success
	! ../script/run-test.sh timeout.test.service failure
	  ../script/run-test.sh timeout.test.service timeout

test-general: test-sanity
	  ../script/run-test.sh hosts-file.test.service

test-skydns: test-sanity
	../script/run-test.sh skydns-running.test.service
	../script/run-test.sh skydns-resolvconf.test.service
	../script/run-test.sh skydns-external.test.service
	../script/run-test.sh skydns-wildcards.test.service

test-monitord: 
	@# test-sanity test-skydns
	../script/run-test.sh monitord-running.test.service
	../script/run-test.sh monitord-to-riemann.test.service
	../script/run-test.sh monitord-available.test.service

test-graphite:
	@# test-sanity test-skydns
	fleetctl destroy ../services/graphite.service
	fleetctl start ../services/graphite.service
	../script/run-test.sh graphite-running.test.service
	../script/run-test.sh graphite-available.test.service
	../script/run-test.sh grafana-available.test.service

test-riemann:
	@# test-monitord
	fleetctl destroy ../services/riemann.service
	fleetctl start ../services/riemann.service
	../script/run-test.sh riemann-running.test.service
	../script/run-test.sh riemann-available.test.service
