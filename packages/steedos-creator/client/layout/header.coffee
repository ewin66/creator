Template.creatorHeader.helpers Creator.helpers

Template.creatorHeader.helpers
	logoUrl: ()->
		logo_main_custome = Meteor?.settings?.public?.theme?.logo_main_custome
		if logo_main_custome
			logo_url = logo_main_custome
		else
			logo_url = "/packages/steedos_creator/assets/logo.png"
		return Creator.getRelativeUrl(logo_url)
	
	currentUserUser: ()->
		url = "app/admin/users/view/#{Steedos.userId()}"
		return Creator.getRelativeUrl(url)

	showSwitchOrganization : ()->
		show_switch_organization = Meteor?.settings?.public?.theme?.show_switch_organization
		if show_switch_organization
			return show_switch_organization
		else
			return false
		
	avatarURL: (avatar,w,h,fs) ->
		userId = Meteor.userId()
		avatar = Creator.getCollection("users").findOne({_id: userId})?.avatar
		if avatar
			return Steedos.absoluteUrl("avatar/#{Meteor.userId()}?w=220&h=200&fs=160&avatar=#{avatar}")
		else
			return Creator.getRelativeUrl("/packages/steedos_lightning-design-system/client/images/themes/oneSalesforce/lightning_lite_profile_avatar_96.png")

	displayName: ->
		if Meteor.user()
			return Meteor.user().displayName()
		else
			return " "

	signOutUrl: ()->
		return Creator.getRelativeUrl("/steedos/logout")

	isAdmin: ()->
		return Steedos.isSpaceAdmin()

	showShopping: ()->
		return Steedos.isSpaceAdmin() && !_.isEmpty(Creator?._TEMPLATE?.Apps)


Template.creatorHeader.events

	'click .creator-button-setup': (e, t)->
		FlowRouter.go("/app/admin")

	'click .creator-button-help': (e, t)->
		Steedos.openWindow("https://www.steedos.com/cn/help/creator/")

	'click .creator-button-shopping': (e, t)->
		Modal.show('template_apps_list_modal')
		
	'click .creator-button-toggle': (e, t)->
		Modal.show("list_tree_modal")

	'click .current-user-link': (e, t)->
		url = "/app/admin/users/view/#{Steedos.userId()}"
		FlowRouter.go(url)
