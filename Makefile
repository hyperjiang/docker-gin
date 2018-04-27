all: help

APP=$(shell basename $(shell pwd))
GOLANG_IMG=hyperjiang/golang:1.10.1

#####   ####   ####  #    # ###### #####
#    # #    # #    # #   #  #      #    #
#    # #    # #      ####   #####  #    #
#    # #    # #      #  #   #      #####
#    # #    # #    # #   #  #      #   #
#####   ####   ####  #    # ###### #    #

help:
	###########################################################################################################
	# [DOCKER]
	# make dev-backend         - create docker bridge network "dev-backend"
	# make ps                   - docker ps -a (list all containers)
	# make up                   - run docker-compose up (run up the container)
	# make down                 - run docker-compose down (shutdown the container)
	# make kill                 - run docker-compose rm -f (kill and rm the container)
	# make restart              - run docker-compose restart (restart the container)
	# make logs                 - tail the container logs
	# make clean                - run: make rm-con, make rm-img
	# make stats                - show container stats (CPU%, memory, etc)
	# make stats-all            - show all containers stats (CPU%, memory, etc)
	# make sh                   - enter the container
	# make cli                  - run a new container as client on HOST network (golang docker image)
	# make golang               - run a new container with code mounted (golang docker image)
	# rm-con                    - remove all dead containers (non-zero Exited)
	# rm-img                    - remove all <none> images/layers
	#
	# [PROJECT]
	# dep-init                  - run "dep init"
	# dep-ensure                - run "dep ensure"
	# dep-ensure-vendor         - run "dep ensure -vendor-only"
	#
	# [MICROSERVICE]
	# gotest                    - run "go test" in container
	# gofmt                     - format golang source code (change the codes)
	# godoc                     - serve godoc for source code and open in browser (Mac)
	###########################################################################################################
	@echo "Enjoy!"

dev-backend:
	docker network create -d bridge dev-backend || true

ps:
	docker ps -a

up: dev-backend
	docker-compose -f dev-docker-compose.yml up --build -d

down:
	docker-compose -f dev-docker-compose.yml down

kill:
	docker-compose -f dev-docker-compose.yml kill && \
	docker-compose -f dev-docker-compose.yml rm -f

restart:
	docker-compose -f dev-docker-compose.yml restart

logs:
	docker-compose -f dev-docker-compose.yml logs -f --tail=10

clean-vendor:
	rm -rf ./src/vendor/*

clean: rm-img clean-vendor

stats:
	docker stats dev-${APP}

stats-all:
	docker stats `docker ps -a | sed 1d | awk '{print $$NF}'`

sh:
	docker-compose -f dev-docker-compose.yml exec dev-${APP} bash

cli:
	docker run --rm -it --net=host "${GOLANG_IMG}" bash

rm-con:
	deads=$$(docker ps -a | sed 1d | grep "Exited " | grep -v "Exited (0)" | awk '{print $$1}'); if [ "$$deads" != "" ]; then docker rm -f $$deads; fi

rm-img: rm-con
	none=$$(docker images | sed 1d | grep "^<none>" | awk '{print $$3}'); if [ "$$none" != "" ]; then docker rmi $$none; fi

###### #    #  ####  #    # #####  ######
#      ##   # #      #    # #    # #
#####  # #  #  ####  #    # #    # #####
#      #  # #      # #    # #####  #
#      #   ## #    # #    # #   #  #
###### #    #  ####   ####  #    # ######

dep-init:
	########################################################
	# Will create Gopkg.lock Gopkg.toml and vendor/ folder #
	########################################################
	docker run --rm -t -v "${PWD}/src:/go/src/${APP}" -w "/go/src/${APP}" "${GOLANG_IMG}" dep init -v

dep-ensure:
	docker run --rm -t -v "${PWD}/src:/go/src/${APP}" -w "/go/src/${APP}" "${GOLANG_IMG}" dep ensure -v

dep-ensure-vendor:
	docker run --rm -t -v "${PWD}/src:/go/src/${APP}" -w "/go/src/${APP}" "${GOLANG_IMG}" dep ensure -v -vendor-only

#    # #  ####  #####   ####      ####  ###### #####  #    # #  ####  ######
##  ## # #    # #    # #    #    #      #      #    # #    # # #    # #
# ## # # #      #    # #    #     ####  #####  #    # #    # # #      #####
#    # # #      #####  #    #         # #      #####  #    # # #      #
#    # # #    # #   #  #    #    #    # #      #   #   #  #  # #    # #
#    # #  ####  #    #  ####      ####  ###### #    #   ##   #  ####  ######

golang: dev-backend dep-ensure-vendor
	docker run --rm -it --net=host -v "${PWD}/src:/go/src/${APP}" -w "/go/src/${APP}" -e ENV=dev "${GOLANG_IMG}" bash

gotest: dev-backend dep-ensure-vendor
	docker run --rm -it --net=host -v "${PWD}/src:/go/src/${APP}" -v "${PWD}/app:/app" -w "/go/src/${APP}" -e ENV=dev "${GOLANG_IMG}" bash -c "go test -cover ./..."

gofmt:
	docker run --rm -t -v "${PWD}/src:/go/src/${APP}" -w "/go/src/${APP}" "${GOLANG_IMG}" gofmt -w .

godoc:
	@docker rm -f dev-$(APP)-godoc || true
	@while [ true ]; do \
		PORT=$$(( ( RANDOM % 60000 )  + 1025 )); \
		nc -z -vv localhost $$PORT >/dev/null 2>/dev/null || break; \
	done; \
	docker run --rm -it --net=dev-backend -v "${PWD}/src:/go/src/${APP}" -w "/go/src/${APP}" \
		--expose=80 -p "$$PORT:80" \
		-e ENV=dev -d --name=dev-$(APP)-godoc "${GOLANG_IMG}" bash -c \
		"godoc -http :80";\
	docUrl="http://localhost:$$PORT/pkg/$(APP)"; \
	sleep 3s ; os=$$(uname -s); if [ "$$os" == Darwin ]; then echo "Opening browser..."; open "$$docUrl"; fi; \
