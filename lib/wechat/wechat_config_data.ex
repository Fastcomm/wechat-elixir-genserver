defmodule Wechat.ConfigData do

  defstruct appid: nil,
            secret: nil,
            token: Application.get_env(:wechat, Wechat)[:token],
            encoding_aes_key: Application.get_env(:wechat, Wechat)[:encoding_aes_key],
            token_file: "/tmp/access_token"
  end
