defmodule Wechat.ConfigData do

  defstruct  appid: nil,
              secret: nil,
              token: nil,
              encoding_aes_key: nil,
              token_file: "/tmp/access_token"
  end
