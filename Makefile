include .env

clean:
	rm -rf output cache

build:
	docker build -t tinfoil-modelpack .

pack:
	docker run --rm -it \
		-v $(shell pwd)/cache:/cache:Z \
		-v $(shell pwd)/output:/output:Z \
		-e HF_TOKEN=${HF_TOKEN} \
		-e MODEL=$(word 2,$(MAKECMDGOALS)) \
		tinfoil-modelpack

%:
	@:
