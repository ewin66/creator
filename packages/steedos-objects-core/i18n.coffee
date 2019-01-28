import i18n from 'meteor/universe:i18n';
sprintf = require('sprintf-js').sprintf;
@i18n = i18n;

@t = (key, parameters, locale) ->
	if locale == "zh-cn"
		locale = "zh-CN"

	if locale
		translator = i18n.createTranslator('', locale);
	else
		translator = i18n.__;

	if parameters?.context
		key = key + "_" + parameters.context;
			
	if parameters? and !(_.isObject parameters)
		# 兼容老格式 key中包含 %s，只支持一个参数。
		return sprintf(translator(key), parameters)

	return translator(key, parameters)

@tr = t

@trl = t

# 重写tap:i18n函数，向后兼容
i18n.setOptions
	purify: null
	defaultLocale: 'zh-CN'

if TAPi18n?
	TAPi18n.__original = TAPi18n.__
	TAPi18n.__ = (key, options, locale)->

		translated = t(key, options, locale);		
		return translated

		# i18n 翻译不出来，尝试用 tap:i18n 翻译
		return TAPi18n.__original key, options, locale

if Meteor.isClient
	getBrowserLocale = ()->
		l = window.navigator.userLanguage || window.navigator.language || 'en'
		if l.indexOf("zh") >=0
			locale = "zh-cn"
		else
			locale = "en-us"
		return locale


	SimpleSchema.prototype.i18n = (prefix) ->
		self = this
		_.each(self._schema, (value, key) ->
			if (!value)
				return
			if !self._schema[key].label
				self._schema[key].label = ()->
					return t(prefix + "_" + key.replace(/\./g,"_"))
		)

	Template.registerHelper '_', (key, args)->
		return t(key, args);

	Session.set("steedos-locale", getBrowserLocale())

	Tracker.autorun ()->
		if Session.get("steedos-locale") != "en-us"
			if TAPi18n?
				TAPi18n.setLanguage("zh-CN")
			T9n.setLanguage("zh-CN")
			i18n.setLocale("zh-CN")
			moment.locale("zh-cn")
		else
			if TAPi18n?
				TAPi18n.setLanguage("en")
			T9n.setLanguage("en")
			i18n.setLocale("en")
			moment.locale("en")

	Tracker.autorun ()->
		if Meteor.user()
			if Meteor.user().locale
				Session.set("steedos-locale",Meteor.user().locale)

	Meteor.startup ->

		Template.registerHelper '_', (key, args)->
			return t(key, args);
		


		Tracker.autorun ->
			lang = Session.get("steedos-locale")

			$.extend true, $.fn.dataTable.defaults,
				language:
					"decimal":        t("dataTables.decimal"),
					"emptyTable":     t("dataTables.emptyTable"),
					"info":           t("dataTables.info"),
					"infoEmpty":      t("dataTables.infoEmpty"),
					"infoFiltered":   t("dataTables.infoFiltered"),
					"infoPostFix":    t("dataTables.infoPostFix"),
					"thousands":      t("dataTables.thousands"),
					"lengthMenu":     t("dataTables.lengthMenu"),
					"loadingRecords": t("dataTables.loadingRecords"),
					"processing":     t("dataTables.processing"),
					"search":         t("dataTables.search"),
					"zeroRecords":    t("dataTables.zeroRecords"),
					"paginate":
						"first":      t("dataTables.paginate.first"),
						"last":       t("dataTables.paginate.last"),
						"next":       t("dataTables.paginate.next"),
						"previous":   t("dataTables.paginate.previous")
					"aria":
						"sortAscending":  t("dataTables.aria.sortAscending"),
						"sortDescending": t("dataTables.aria.sortDescending")

			_.each Tabular.tablesByName, (table) ->
				_.each table.options.columns, (column) ->
					if (!column.data || column.data == "_id")
						return
					column.sTitle = t("" + table.collection._name + "_" + column.data.replace(/\./g,"_"));
					if !table.options.language
						table.options.language = {}
					table.options.language.zeroRecords = t("dataTables.zero") + t(table.collection._name)
					return 


