# CI for Drupal

This repository contains a Dockerfile and a Makefile to build a Drupal container with PHP 8.4, Drupal 11.x-dev and XDebug 3.4.1 for testing purposes (unit and kernel only).

The goal is to have a docker image that can be used to run tests for separate modules.

## Usage

### Pull the image

This image contain the PHP 8.4 with XDebug 3.4.1 and the Drupal 11.x-dev version.

```bash
docker pull ghcr.io/spooky063/standalone-drupal:v1.0.0
```

### Use this image to run tests

You can pass your own phpunit.xml.dist file and your modules to test.

```bash
docker run -it --rm \
-e SIMPLETEST_DB=sqlite://localhost/sites/default/files/.test.sqlite \
-e SIMPLETEST_BASE_URL=http://localhost \
-v ./phpunit.xml.dist:/srv/app/phpunit.xml.dist:ro \
-v ./modules:/srv/app/web/modules/custom:ro \
ghcr.io/spooky063/standalone-drupal:v1.0.0 \
phpunit --testdox --testsuite unit,kernel --coverage-text
```