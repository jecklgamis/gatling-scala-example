default:
	cat ./Makefile
create-job-yaml:
	./create-job-yaml.py --java_opts "-DbaseUrl=http://172.16.0.50:8080 -DdurationMin=0.25 -DrequestPerSecond=10" --simulation "gatling.test.example.simulation.ExampleGetSimulation"
apply:
	kubectl apply -f job.yaml
delete:
	kubectl delete -f job.yaml
get-jobs:
	kubectl get jobs/gatling-test-example
get-pods:
	kubectl get pods -l job-name==gatling-test-example
