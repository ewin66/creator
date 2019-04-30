steedosCord = require('@steedos/core')
steedosCord.getObjectConfigManager().loadStandardObjects()
# Creator.Objects = steedosCord.Objects
# Creator.Reports = steedosCord.Reports
Meteor.startup ->
	try
		objectql = require("@steedos/objectql")
		newObjects = {}
		objectsRolesPermission = {}
		_.each Creator.Objects, (obj, key)->
			if /^[_a-zA-Z][_a-zA-Z0-9]*$/.test(key)
				newObjects[key] = obj
			objectsRolesPermission[key] = obj.permission_set

		Creator.steedosSchema = objectql.getSteedosSchema()

		Creator.steedosSchema.addDataSource('default',{
			driver: 'meteor-mongo'
			objects: newObjects
			objectsRolesPermission: objectsRolesPermission
			getRoles: (userId)->
				# TODO 获取用户角色
				return ['admin']
		})

		#### 测试代码开始 TODO:remove ####
		path =require('path')
		testRootDir = path.resolve('../../../../../test')
		console.log('testRootDir', testRootDir);
		Creator.steedosSchema.addDataSource('mall', {
			driver: "sqlite",
			url: path.join(testRootDir, 'mall.db'),
			objectFiles: [path.join(testRootDir, 'mall')]
		})

		Creator.steedosSchema.useAppFile(path.join(testRootDir, 'mall'))

		Creator.steedosSchema.getDataSource('mall').createTables()

		Creator.steedosSchema.addDataSource('stock', {
			driver: "sqlserver",
			options: {
				tdsVersion: "7_2"
			},
			url: "mssql://sa:hotoainc.@192.168.0.190/hotoa_main_stock",
			objectFiles: [path.join(testRootDir, 'stock')]
		})

		Creator.steedosSchema.useAppFile(path.join(testRootDir, 'stock'))

		Creator.steedosSchema.getDataSource('stock').createTables()

		Creator.steedosSchema.addDataSource('pdrq', {
			driver: "sqlserver",
			options: {
				tdsVersion: "7_2"
			},
			url: "mssql://sa:hotoainc.@192.168.0.235/hotoa_main_svn",
			objectFiles: [path.join(testRootDir, 'pdrq_contracts')]
		})

		Creator.steedosSchema.useAppFile(path.join(testRootDir, 'pdrq_contracts'))

		Creator.steedosSchema.getDataSource('pdrq').createTables()

		Creator.steedosSchema.addDataSource('mongo', {
			driver: "mongo"
			url: "mongodb://127.0.0.1/mongo",
			objectFiles: [path.join(testRootDir, 'mongo')]
		})

		Creator.steedosSchema.useAppFile(path.join(testRootDir, 'mongo'))

		Creator.steedosSchema.getDataSource('mongo').createTables()

		#### 测试代码结束 ####
		express = require('express');
		graphqlHTTP = require('express-graphql');
		Cookies = require("cookies");
		app = express();
		router = express.Router();
		router.use((req, res, next)->
			cookies = new Cookies(req, res)
			userId = req.headers['x-user-id'] || cookies.get("X-User-Id")
			authToken = req.headers['x-auth-token'] || cookies.get("X-Auth-Token")
			user = null
			if userId and authToken
				searchQuery = {}
				searchQuery['services.resume.loginTokens.hashedToken'] = Accounts._hashLoginToken authToken
				user = Meteor.users.findOne
					'_id': userId
					searchQuery

			if user
				next();
			else
				res.status(401).send({ errors: [{ 'message': 'You must be logged in to do this.' }] });
		)
		_.each Creator.steedosSchema.getDataSources(), (datasource, name) ->
			router.use("/#{name}", graphqlHTTP({
				schema: datasource.buildGraphQLSchema(),
				graphiql: true
			}))

		app.use('/graphql', router);
		WebApp.connectHandlers.use(app);
	catch e
		console.error(e)