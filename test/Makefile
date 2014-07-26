.PHONY: test test-sanity test-skydns

test: test-sanity test-skydns

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

test-skydns: test-sanity
	../script/run-test.sh skydns-running.test.service
	../script/run-test.sh skydns-resolvconf.test.service
	../script/run-test.sh skydns-external.test.service
	../script/run-test.sh skydns-wildcards.test.service
