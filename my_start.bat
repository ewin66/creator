set DB_SERVER=127.0.0.1
set MONGO_URL=mongodb://%DB_SERVER%/steedos
set MONGO_OPLOG_URL=mongodb://%DB_SERVER%/local
set MULTIPLE_INSTANCES_COLLECTION_NAME=creator_instances
set ROOT_URL=http://192.168.3.2:5001
set TOOL_NODE_FLAGS="--max-old-space-size=3800"
meteor run --port 5001 --settings settings.json
rem meteor run android-device --mobile-server 192.168.3.2:5001 --port 5001 --settings settings.json