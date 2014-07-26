.PHONY: test test-sanity

test: test-sanity

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

