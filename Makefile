.DEFAULT_GOAL := help
help:
	@perl -nle'print $& if m{^[a-zA-Z_-|.]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

run.format: ## Format style with black
	docker-compose -f docker-compose.yaml exec -T django bash -c "black --exclude='/(postgres|venv|migrations|node_modules|\.git)/' ."

docker.bash: ## Enter bash terminal
	docker exec -it formacion-htmx_django_1 bash


docker.recreate.django: ## Recreate Django image
	docker-compose down
	docker-compose build --no-cache django

run.loaddata: ## Minimal load data
	# Remove database
	docker-compose -f docker-compose.yaml exec -T django bash -c "python3 manage.py flush --noinput"
	# Remove media
	sudo rm -rf media
	# Migrate
	docker-compose -f docker-compose.yaml exec -T django bash -c "python3 manage.py migrate"
	# Add categories
	docker-compose -f docker-compose.yaml exec -T django bash -c "python3 manage.py runscript create_categories"
	# Add profiles
	docker-compose -f docker-compose.yaml exec -T django bash -c "python3 manage.py runscript create_profiles"
	# Add talks
	docker-compose -f docker-compose.yaml exec -T django bash -c "python3 manage.py runscript create_talks"

run.server: # Run server
	docker-compose -f docker-compose.yaml up


