# How to Create a Rails API with Docker

This tutorial will give you a path to follow if you're looking for build your own rails project with docker.
In the end you will have a Rails API working with no Ruby or Rails installed in your environment.
For the next steps, be sure you have a Docker and Docker-compose installed in your machine.

## Step 1 - Create a dockerfile
Create a new file named `dockerfile` with a ruby version and a folder for your application

``` dockerfile
FROM ruby:3.2.2

WORKDIR /app
```

## Step 2 - Create a docker-compose
Create a new file named `docker-compose.yml`.

``` yml
  web:
    build:
      context: ./
      dockerfile: dockerfile
    ports:
      - '3000:3000'
    volumes:
      - .:/app
```

This file create a new service web using the dockerfile created in step 1.

## Step 3 - Create a container and install Rails
In your terminal run the command bellow to create a new container with the docker-compose and open bash.

`docker-compose run --service-ports web bash`

Inside the container run:

`gem install rails`

## Step 4 - Create a API Project
After install the rails gem you can use the command line to see the options that you can pass to create your own application.
Here we are creating a API with Postgres and skipping minitest files.

`
rails new . --api --database=postgresql -T
`

Now you should see all the rails files in your current path.


## Step 5 - If you are using Linux
Docker will create the files with root user, run the command bellow to allow you to edit the files created by docker.
The first argument is the current user and the second the current folder.

`sudo chown -R $USER .`


## Step 6 - Change your dockerfile

With your new app generated, it's time to copy the files and install all dependencies.
Add the copy command to copy your files from current path to container. Run the bundle install to install all dependencies.

``` docker
FROM ruby:3.2.2

WORKDIR /app

COPY . .

RUN bundle install
```

## Step 7 - Add database configurations

Create a .env file to add your environment variables for postgres

```
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
```

Edit your docker-compose to add a service database and connect the database with the web container. Add the command to start the rails server when the container up.

``` yml
services:
  db:
    image: postgres
    volumes:
     - ./tmp/db:/var/lib/postgresql/data
    ports:
      - '5432:5432'
    environment:
      - POSTGRES_PASSWORD=${DATABASE_PASSWORD}

  web:
    build:
      context: ./
      dockerfile: dockerfile
    ports:
      - '3000:3000'
    volumes:
      - .:/app
    depends_on:
      - db
    command: rails s -b 0.0.0.0
    environment:
      - DATABASE_HOST=db
    env_file:
      - .env

volumes:
  db:
```

The depends_on argument will avoid the web application up before the database.

## Step 8 - Connect rails app with db container
In `database.yml` update the credentials to allow rails app to connect with service db container using the environment variables.

``` yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: <%= "#{ENV.fetch("DATABASE_HOST")}" %>
  port: <%= "#{ENV.fetch("DATABASE_PORT")}" %>
  username: <%= ENV.fetch("DATABASE_USERNAME") %>
  password: <%= ENV.fetch("DATABASE_PASSWORD") %>
```

## Step 9 - Build the containers

`docker-compose build`

## Step 10 - Create the database

`docker-compose run web bin/rails db:create`

``` bash
[+] Running 1/1
 ⠿ Container products-api-db-1  Created
[+] Running 1/1
 ⠿ Container products-api-db-1  Started
```

## Step 11 - Up the server
Finally you can up the server

`docker-compose up`

Access [localhost:3000 ](http://localhost:3000) in your browser and see the default homepage of rails app

![alt text](image.png)
