.PHONY: build
build:
	docker build \
		--build-arg PHP_VERSION=8.4 \
		--build-arg DRUPAL_VERSION=11.x-dev \
		-t standalone-drupal:latest .

.PHONY: delete-build
delete-build:
	docker image rm -f standalone-drupal:latest
	@bash -c 'trap "exit 0" SIGINT; docker rm standalone-drupal'

.PHONY: run
run:
	@bash -c 'trap "exit 0" SIGINT; docker rm standalone-drupal'
	docker run -it --name "standalone-drupal" \
	-p 80:80 \
	-e SIMPLETEST_DB=sqlite://localhost/sites/default/files/.test.sqlite \
	-e SIMPLETEST_BASE_URL=http://localhost \
	-v ./phpunit.xml.dist:/srv/app/phpunit.xml.dist:ro \
	-v ./modules:/srv/app/web/modules/custom:ro \
	standalone-drupal:latest \
	phpunit --testdox --testsuite unit,kernel --coverage-text

.PHONY: ssh
ssh:
	docker exec -it $(shell docker container ls --all --filter "name=standalone-drupal" --quiet) sh

.PHONY: github@pull
github@pull:
	docker pull ghcr.io/spooky063/standalone-drupal:main

.PHONY: github@run
github@run:
	@bash -c 'trap "exit 0" SIGINT; docker rm github-standalone-drupal'
	docker run -it --name "github-standalone-drupal" \
	-p 80:80 \
	-e SIMPLETEST_DB=sqlite://localhost/sites/default/files/.test.sqlite \
	-e SIMPLETEST_BASE_URL=http://localhost \
	-v ./phpunit.xml.dist:/srv/app/phpunit.xml.dist:ro \
	-v ./modules:/srv/app/web/modules/custom:ro \
	ghcr.io/spooky063/standalone-drupal:main \
	phpunit --testdox --testsuite unit,kernel --coverage-text