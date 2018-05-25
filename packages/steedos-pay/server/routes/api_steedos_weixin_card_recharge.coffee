import WXPay from '../lib/wxpay.js'
import util from '../lib/util.js'

JsonRoutes.add 'post', '/api/steedos/weixin/card/recharge', (req, res, next) ->
    try
        current_user_info = payManager.check_authorization(req, res)
        user_id = current_user_info._id

        body = req.body
        totalFee = body.totalFee
        cardId = body.cardId

        sub_appid = req.headers['appid']

        check totalFee, Number
        check cardId, String
        check sub_appid, String

        card = Creator.getCollection('vip_card').findOne(cardId, { fields: { space: 1, store: 1 } })

        if not card
            throw new Meteor.Error('error', "未找到会员卡")

        store = Creator.getCollection('vip_store').findOne(card.store, { fields: { mch_id: 1 } })

        if not store
            throw new Meteor.Error('error', "未找到门店")

        # sub_mch_id = '1504795791'
        sub_mch_id = store.mch_id

        returnData = {}

        listprices = 0
        order_body = '会员充值'

        attach = {}
        attach.record_id = Creator.getCollection('billing_record')._makeNewID()

        sub_openid = ''
        current_user_info.services.weixin.openid.forEach (o) ->
            if not sub_openid and o.appid is sub_appid
                sub_openid = o._id

        wxpay = WXPay({
            appid: Meteor.settings.billing.appid,
            mch_id: Meteor.settings.billing.mch_id,
            partner_key: Meteor.settings.billing.partner_key #微信商户平台API密钥
        })

        out_trade_no = moment().format('YYYYMMDDHHmmssSSS')

        orderData = {
            body: order_body,
            out_trade_no: out_trade_no,
            total_fee: totalFee,
            spbill_create_ip: '127.0.0.1',
            notify_url: Meteor.absoluteUrl() + 'api/steedos/weixin/card/recharge/notify',
            trade_type: 'JSAPI', # 小程序取值如下：JSAPI
            attach: JSON.stringify(attach),
            sub_appid: sub_appid,
            sub_mch_id: sub_mch_id,
            sub_openid: sub_openid
        }

        result = wxpay.createUnifiedOrder(orderData, Meteor.bindEnvironment(((err, result) ->
                if err
                    console.error err.stack
                if result and result.return_code is 'SUCCESS' and result.result_code is 'SUCCESS'
                    obj = {
                        _id: attach.record_id
                        paid: false
                        info: result
                        total_fee: totalFee
                        owner: user_id
                        space: card.space
                        store: card.store
                        card: card._id
                        out_trade_no: out_trade_no
                    }

                    Creator.getCollection('billing_record').insert(obj)

                    returnData.timeStamp = Math.floor(Date.now() / 1000) + ""
                    returnData.nonceStr = util.generateNonceString()
                    returnData.package = "prepay_id=#{result.prepay_id}"
                    returnData.paySign = wxpay.sign({
                        appId: sub_appid
                        timeStamp: returnData.timeStamp
                        nonceStr: returnData.nonceStr
                        package: returnData.package
                        signType: 'MD5'
                    })
                else
                    console.error result
            ), ()->
                console.log 'Failed to bind environment'
            )
        )

        JsonRoutes.sendResult res,
            code: 200
            data: returnData
    catch e
        console.error e.stack
        JsonRoutes.sendResult res,
            code: 200
            data: { errors: [ { errorMessage: e.message } ] }

