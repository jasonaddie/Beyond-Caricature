# Beyond Caricature
This is a Ruby on Rails digital library to store illustrations in publications from the Caucasus region in the early 1900s.


# Dependencies

* Ruby - 2.5.3
* Rails - 5.2.1
* PostgreSQL - 10
* Imagemagick
* Docker - 18
* Docker-engine - 18
* Docker-compose - 1.22

# Gems
The following are Gems that are used in the app.

* Rails Admin - admin interface for inputting content
* Rails Admin Material - theme for Rails Admin
* Devise - authentication
* CanCanCan - authorization
* PaperTrail - keep history of all transactions
* Globalize - translate content
* CKEditor - WYSIWYG text editor
* Dragonfly - Image/File processing and storage to S3


# Getting Started

## Environemnt Variables
At the root of the project is `.env.template`. This is a template file for all of the required environmental variables for the app (db credentials, keys, etc). You should duplicate this file with the name of `.env` and fill in the appropriate values. IF you are going to be deploying, you should also create a `.env.production` file and fill in the correct values for the production server.

## Docker
This app uses [Docker](https://www.docker.com/) to have the app, database, etc all in containers so it is easy to get up and going with the app. You will need to install the following docker packages:

* [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) - base docker code
* [Docker-compose](https://docs.docker.com/compose/install/) - indicate images and settings to use to build and run the app
* [Docker-machine](https://docs.docker.com/machine/install-machine/) - deploy updates to the server

Once the docker packages are installed, simply run `docker-compose up` to start the site. You can find more [useful docker commands here](http://files.zeroturnaround.com/pdf/zt_docker_cheat_sheet.pdf).

For the development environment, you can use the normal Rails process to run the app (bundle install and rails s). But the deploy process uses docker-machine so it is strongly advised that you also test the development through docker to make sure everything is working properly.


# Deploying the app
Docker Machine and Docker Compose are being used to deploy the application to the server. You can find the [docker machine install instructions here](https://docs.docker.com/machine/install-machine/).

## The basic steps that will be taken are the following:
* Make changes to the code
* Re-build the app image
* Tag the app image with a new version
* Push the image to docker hub
* Update docker-compose.prod.yml to use the new app version number
* Use docker machine to connect to the server
* Run docker compose up to update the server
* Close connection to server

## The details

### Updating the image

After code has been updated, the app image needs to be re-created. Do this by deleting the app container and image and then call `docker-compose build` to build the image.

* `docker ps -a` - get id of container to stop
* `docker rm <cont_id>` - remove container
* `docker images` - get id of image to stop
* `docker rmi <img_id>` - remove image
* `docker-compose up` - rebuild image

### Pushing the image to docker hub

Now that the image has be created, we need to push it to docker hub so the server can pull the image down and use it. You can [log into docker hub](http://hub.docker.com/) to see what versions on are on file.

Before you can do this, you have to log into docker hub through the command line:
```bash
docker login
```

To tag the new image version, use this command: `docker tag image username/repository:tag`

* image is the name of the image
* username is the docker hub username
* repository is the name of the repo on docker hub
* tag is where you indicate the version

Tag value - when you create the new tag version, just increase the last number by one. If this is a major release, then go ahead and update the first number by one.

For this project the command is:
```bash
docker tag beyond-caricature_app schmerling/app:0.1
```
Note - `beyond-caricature_app` is what the image is called on my machine because it is in a beyond-caricature folder. It may be different on your machine, so make sure you use the correct name.

Now that the image is tagged, let's push it up to docker hub:
```bash
docker push schmerling/app:0.1
```
Note - this may take a few minutes to upload to the server.

### Update the image on the server
Now that the new image is on docker hub, we can log into the server and tell it to use it.

First, you must update the app image name in `docker-compose.prod.yml` to use the latest version.

Next, you can use docker-machine to connect to the server. If you did not install the 3 docker machine scripts, use the following code:
```bash
eval $(docker-machine env schmerling)
```
```bash
docker-machine use schmerling-production
```
or
```bash
docker-machine use schmerling-staging
```

Now you can run docker compose to update the images on the server. IMPORTANT - you must reference the docker-compose.prod.yml file in the docker-compose statement so the production settings are used on the server.
```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```
or
```bash
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d
```

If you need to perform any migration or anything else on the app image, you can use `docker exec` to get into the image and do what needs to be done.

The site is now updated.

Finally, close the docker machine connection so all docker commands are now running locally on your machine:
```bash
docker-machine use -u
```