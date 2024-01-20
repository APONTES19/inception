# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: lucasmar < lucasmar@student.42sp.org.br    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/09/12 15:13:15 by lucasmar          #+#    #+#              #
#    Updated: 2023/12/12 17:31:51 by lucasmar         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# inputs ********************************************************************* #
NAME			= Inception

LOGIN			= lucasmar
COMPOSE			= srcs/docker-compose.yml
VOLUMES_PATH	= /home/$(LOGIN)/data

DOMAIN			= 127.0.0.1	$(LOGIN).42.fr
LOOKDOMAIN		= $(shell grep "${DOMAIN}" /etc/hosts)

export VOLUMES_PATH

all: srcs/.env hosts crVolumes compose

# message in terminal ************ #
	@echo "\033[1;32m"
	@echo "	$(NAME) created ✓"
	@echo "\033[0m"
	@echo "\033[0;33m	Welcome to $(NAME) by lucasmar 42sp \033[0m"

# build ********************************************************************* #

srcs/.env:
	@echo "Missing .env file in srcs folder" && exit 1

hosts:
	@if [ "${DOMAIN}" = "${LOOKDOMAIN}" ]; then \
		echo "Host already set"; \
	else \
		cp /etc/hosts ./hosts_bkp; \
		sudo rm /etc/hosts; \
		sudo cp ./srcs/requirements/tools/hosts /etc/hosts; \
	fi

update:
	sudo apt update && sudo apt upgrade -y
	sudo apt-get install docker-compose-plugin

# Docker ********************************************************************* #

dkls:
	docker ps -a
dknet:
	docker network ls
dkvl:
	docker volume ls

compose:
	docker compose --file=$(COMPOSE) up --build --detach

crVolumes:
	sudo mkdir -p $(VOLUMES_PATH)/mysql
	docker volume create --name mariadb_volume --opt type=none --opt device=$(VOLUMES_PATH)/mysql --opt o=bind
	sudo mkdir -p $(VOLUMES_PATH)/wordpress
	docker volume create --name wordpress_volume --opt type=none --opt device=$(VOLUMES_PATH)/wordpress --opt o=bind

# clean ********************************************************************** #

down:
	docker compose --file=$(COMPOSE) down -v --rmi all --remove-orphans

clean: down
		@docker system prune --all --force --volumes
		@echo "\033[0;31m       ▥ $(NAME) objets clean ✓ \033[0m"

fclean: clean
	@$(RM) $(NAME)
		@sudo mv ./hosts_bkp /etc/hosts || echo "hosts_bkp does not exist"
		@sudo rm -rf $(VOLUMES_PATH)/wordpress
		@sudo rm -rf $(VOLUMES_PATH)/mysql
		@docker volume rm mariadb_volume
		@docker volume rm wordpress_volume
		@echo "\033[0;31m       ▥ $(NAME) clean ✓ \033[0m"
re:	fclean all

.PHONY: all clean re fclean
