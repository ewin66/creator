Workflow = {}

@ImageSign = {};

@TracesTemplate = {};

@InstanceformTemplate = {};

@InstanceAttachmentTemplate = {};

@InstanceSignText = {}

@RelatedInstances = {}

@InstanceMacro = {context: {}}

@TracesManager = {};

if Meteor.isClient
	Meteor.startup ->
		workflow_three_columns = localStorage.getItem("workflow_three_columns")
		if workflow_three_columns and workflow_three_columns == "off"
			$("body").removeClass("three-columns")
		else
			$("body").addClass("three-columns")


InstanceSignText.isOpinionField_from_string = (field_formula)->
	return (field_formula?.indexOf("{traces.") > -1 || field_formula?.indexOf("{signature.traces.") > -1 || field_formula?.indexOf("{yijianlan:") > -1 || field_formula?.indexOf("{\"yijianlan\":") > -1 || field_formula?.indexOf("{'yijianlan':") > -1)

InstanceSignText.includesOpinionField = (form, form_version)->
	field_formulas = new Array();

	_form_version = {}

	if Meteor.isServer
		_form_version = uuflowManager.getFormVersion(db.forms.findOne({_id: form}), form_version)
	else
		_form_version = db.form_versions.findOne({_id: form_version, form: form})

	fields = _form_version?.fields || []

	fields.forEach (f)->
		if f.type == 'table'
			console.log 'ignore opinion field in table'
		else if f.type == 'section'
			f?.fields?.forEach (f1)->
				field_formulas.push f1.formula
		else
			field_formulas.push f.formula

	_.some field_formulas, (field_formula)->
		return InstanceformTemplate.helpers.isOpinionField_from_string(field_formula)

