
# Production

## Launch services
```
export PROJECT_NAME=geocoder
mkdir -p ./docker/redis
docker stack deploy -c ./docker-compose.yml ${PROJECT_NAME}
```

## Data build
Then use the configuration file and edit it to match your needs:

```bash
cp ../config/environments/production.rb ./
```

Finally run the services:
```
docker-compose up -d
```

Initialization
--------------

After the first deployment, you need to initialize Addok database.

First, download and put json files in `data` directory. You may may to prefix them with numbers to ensure the order of the import.

Then run the initialization script:

```
./builder/initialize-fr.sh
./builder/initialize-lu.sh
```
