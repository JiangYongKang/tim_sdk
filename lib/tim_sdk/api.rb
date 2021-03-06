require 'faraday'

module TimSdk
  class Api

    def self.connection
      Faraday.new('https://console.tim.qq.com', params: {
          sdkappid:    TimSdk.configuration.app_id,
          identifier:  TimSdk.configuration.admin_account,
          usersig:     TimSdk::Sign.signature(TimSdk.configuration.admin_account),
          random:      rand(0..4294967295),
          contenttype: :json
      }) do |faraday|
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end
    end

    # 导入单个帐号
    def self.invoke_account_import(identifier, nick = nil, face_url = nil)
      response = connection.post('/v4/im_open_login_svc/account_import') do |request|
        request_body = { :Identifier => identifier.to_s }
        request_body.merge!(:Nick => nick) if nick
        request_body.merge!(:FaceUrl => face_url) if face_url
        request.body = request_body.to_json
      end
      raise TimServerError, "Response Status: #{response.status}" unless response.success?
      JSON.parse(response.body, symbolize_names: true) if response.success?
    end

    # 导入多个账号
    def self.invoke_multi_account_import(accounts)
      response = connection.post('/v4/im_open_login_svc/multiaccount_import') do |request|
        request.body = {
            :Accounts => accounts.map(&:to_s)
        }.to_json
      end
      raise TimServerError, "Response Status: #{response.status}" unless response.success?
      JSON.parse(response.body, symbolize_names: true) if response.success?
    end

    # 删除账号
    def self.invoke_account_delete(accounts)
      response = connection.post('/v4/im_open_login_svc/account_delete') do |request|
        request.body = {
            :DeleteItem => accounts.map do |account|
              {
                  :UserID => account.to_s
              }
            end
        }.to_json
      end
      raise TimServerError, "Response Status: #{response.status}" unless response.success?
      JSON.parse(response.body, symbolize_names: true) if response.success?
    end

    # 查询账号
    def self.invoke_account_check(accounts)
      response = connection.post('/v4/im_open_login_svc/account_check') do |request|
        request.body = {
            :CheckItem => accounts.map do |account|
              {
                  :UserID => account.to_s
              }
            end
        }.to_json
      end
      raise TimServerError, "Response Status: #{response.status}" unless response.success?
      JSON.parse(response.body, symbolize_names: true) if response.success?
    end

    # 失效帐号登录态
    def self.invoke_kick(identifier)
      response = connection.post('/v4/im_open_login_svc/kick') do |request|
        request.body = {
            :Identifier => identifier.to_s
        }.to_json
      end
      raise TimServerError, "Response Status: #{response.status}" unless response.success?
      JSON.parse(response.body, symbolize_names: true) if response.success?
    end

    # 查询帐号在线状态
    def self.invoke_query_state(accounts, is_need_detail = 0)
      response = connection.post('/v4/openim/querystate') do |request|
        request.body = {
            :To_Account   => accounts.map(&:to_s),
            :IsNeedDetail => is_need_detail
        }.to_json
      end
      raise TimServerError, "Response Status: #{response.status}" unless response.success?
      JSON.parse(response.body, symbolize_names: true) if response.success?
    end

    # 导入单聊消息
    def self.invoke_import_msg(from_account, to_account, msg_random, msg_timestamp, sync_from_old_system, msg_body)
      response = connection.post('/v4/openim/importmsg') do |request|
        request.body = {
            :SyncFromOldSystem => sync_from_old_system,
            :From_Account      => from_account.to_s,
            :To_Account        => to_account.to_s,
            :MsgRandom         => msg_random.to_i,
            :MsgTimeStamp      => msg_timestamp.to_i,
            :MsgBody           => msg_body
        }.to_json
      end
      raise TimServerError, "Response Status: #{response.status}" unless response.success?
      JSON.parse(response.body, symbolize_names: true) if response.success?
    end

    # 撤回单聊消息
    def self.invoke_admin_msg_withdraw(from_account, to_account, msg_key)
      response = connection.post('/v4/openim/admin_msgwithdraw') do |request|
        request.body = {
            :From_Account => from_account.to_s,
            :To_Account   => to_account.to_s,
            :MsgKey       => msg_key.to_s,
        }.to_json
      end
      raise TimServerError, "Response Status: #{response.status}" unless response.success?
      JSON.parse(response.body, symbolize_names: true) if response.success?
    end

    # 设置资料
    def self.invoke_portrait_set(account, items)
      response = connection.post('/v4/profile/portrait_set') do |request|
        request.body = {
            :From_Account => account.to_s,
            :ProfileItem  => items.map do |item|
              {
                  :Tag   => item[:tag],
                  :Value => item[:value],
              }
            end
        }.to_json
      end
      raise TimServerError, "Response Status: #{response.status}" unless response.success?
      JSON.parse(response.body, symbolize_names: true) if response.success?
    end

    # 拉取资料
    def self.invoke_portrait_get(accounts, tags)
      response = connection.post('/v4/profile/portrait_get') do |request|
        request.body = {
            :To_Account => accounts.map(&:to_s),
            :TagList    => tags.map(&:to_s),
        }.to_json
      end
      raise TimServerError, "Response Status: #{response.status}" unless response.success?
      JSON.parse(response.body, symbolize_names: true) if response.success?
    end

    # 拉取运营数据
    def self.invoke_fetch_app_info(fields = [])
      response = connection.post('/v4/openconfigsvr/getappinfo') do |request|
        request.body = {
            :RequestField => fields
        }.to_json
      end
      raise TimServerError, "Response Status: #{response.status}" unless response.success?
      JSON.parse(response.body, symbolize_names: true) if response.success?
    end

    # 下载消息记录
    def self.invoke_fetch_history(chat_type, msg_time)
      response = connection.post('/v4/open_msg_svc/get_history') do |request|
        request.body = {
            :ChatType => chat_type,
            :MsgTime  => msg_time,
        }.to_json
      end
      raise TimServerError, "Response Status: #{response.status}" unless response.success?
      JSON.parse(response.body, symbolize_names: true) if response.success?
    end

    # 获取服务器 IP 地址
    def self.invoke_fetch_ip_list
      response = connection.post('/v4/ConfigSvc/GetIPList') do |request|
        request.body = {}.to_json
      end
      raise TimServerError, "Response Status: #{response.status}" unless response.success?
      JSON.parse(response.body, symbolize_names: true) if response.success?
    end

  end
end