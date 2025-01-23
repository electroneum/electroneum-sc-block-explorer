# Local Development Guide for Electroneum Smartchain Block Explorer

This guide provides a step-by-step process to run and test your changes for the Electroneum Smartchain Block Explorer. 

The application will run in docker, and you will be able to test your work live by making changes to the codebase on your local machine.

---

## Prerequisites

- Erlang & Elixir SDK
- Some coding IDE (this guide uses intelliJ IDEA as an example)
- Docker (Docker desktop is convenient)
- Docker Compose

## Running the Application

### 1. Logger Configuration

Adjust the logger level in `/config/dev.exs` for more visibility during development:

- **For detailed logs**:
  ```elixir
  config :logger, :console, level: :debug
  ```

- **If logs are too noisy**:
  ```elixir
  config :logger, :console, level: :info
  ```

### 2. Adjust the application listening IP

By default, we listen on all interfaces, but you can modify this inside `/config/dev.exs`

```elixir
      http: [ip: {0, 0, 0, 0}, port: 4000],
```
### 4. Environment variables
Adjust the environmental variables in `/docker-compose/envs/common-blockscout.env` to your liking.

### 5. Building and running the application in Docker

Run the application with the override file for live updates and debugging:
```bash
cd /path/to/electroneum-sc-block-explorer && \
docker build --no-cache -t explorer --build-arg MIX_ENV=dev -f docker/Dockerfile . && \
cd docker-compose && \
docker-compose -f docker-compose-no-build-geth.yml -f docker-compose.ide-debugging.yml up -d
```
This will:
- Build the container in development mode (`MIX_ENV=dev`).
- Map the local codebase (`/apps`, `/envs`, `/config`) into the container.
- Start the Phoenix server with hot reloading enabled for your code changes.

To see your changes, simply refresh the browser window.

## Database Migrations

Ecto `create` and `migrate` commands run automatically during container startup or restart.

## Recreating the Containers

To delete and recreate the containers using the images that you previously built, whilst maintaining the use of the override file:
```bash
docker-compose down
docker-compose -f docker-compose.yml -f docker-compose.ide-debugging.yml up -d
```

## Recompiling the static assets
In development mode, static assets (such as JavaScript, CSS, and images) are not compiled by default to save time and resources during the development workflow. This allows for faster code iteration, as changes to static assets are served directly without requiring additional build steps. Additionally, hot reloading tools ensure that changes to assets are reflected in real-time, further streamlining the development experience.
If you wish to compile the static assets in development mode (e.g., for debugging or to test a production-like behavior), you can do so:

Enter the container, shut down the phoenix server/application, and then navigate to the block_scout_web assets directory:

```bash
cd apps/block_scout_web/assets
```
Install the required Node.js dependencies:
```bash
npm install
```
Compile the static assets:
```bash
npm run deploy
```
Once compiled, you can digest the assets for the Phoenix application:
```bash
mix phx.digest
```

## Reset Your Development Environment

If you need to reset your development environment completely, follow these steps to identify and delete the relevant containers, volumes, and images, as well as remove PostgreSQL data from your local machine.

Here is how you would clear your environment step by step (or you can click-remove in docker-desktop):

1. List all Docker containers:
```bash
docker ps -a
```

2. Gather the NAMES of the containers, and delete the containers
```bash
docker stop blockscout postgres
docker rm blockscout postgres
```
3. Delete the volumes associated with the now deleted containers by using their VOLUME NAME
```bash
docker volume ls
docker volume rm 6b71ecb54b1e3ab3f2f4c4383fe7822cc3daee19ea18019ca35287022e44dea7
docker volume rm 043c4b769bae3948e461e59db0f864babd0ca6b3bc8e9c0c2c6d7a6cf1d0cecf
```

4. Remove the images using their IMAGE ID
```bash
docker images
docker rmi abc123456789 def678901234
```

5. Remove the postgres data stored on your machine
```bash
cd docker-compose && rm -rf postgres-data
```

## IDE Setup for debugging with breakpoints (Work in progress)





