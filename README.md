# Wechat

[![Join the chat at https://gitter.im/goofansu/wechat_elixir](https://badges.gitter.im/goofansu/wechat_elixir.svg)](https://gitter.im/goofansu/wechat_elixir?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Wechat API wrapper in Elixir.

## Installation

1. Add `wechat` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:wechat, "~> 0.1.0"}]
    end
    ```

2. Dont start `wechat` in mix file

3. Start a GenServer (Or start multiple with different account info) with the offical account info:
    ```elixir
    wechat_config_data = %Wechat.ConfigData{appid: my_official_appid,
                                            secret: my_official_secret,
                                            token_file: "/choose/a/temp/location/"} #Default is /tmp/access_token
    Wechat.start(:my_genserver, wechat_config_data)
    ```
## Config

* Add config in `config.exs`

    ```elixir
    config :wechat, Wechat,
      token: "wechat token",
      encoding_aes_key: "32bits key"
    ```

## Usage

* send_text_message
  ```elixir
  Wechat.send_text_message(:my_genserver, open_id, text)
  ```

## Plug

* `Wechat.Plugs.CheckUrlSignature`

  * Check url signature
  * [接入指南](http://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421135319&token=&lang=zh_CN)

* `Wechat.Plugs.CheckMsgSignature`

  * Parse xml message (support decrypt msg)
  * [消息加密解密技术方案](http://mp.weixin.qq.com/wiki/2/3478f69c0d0bbe8deb48d66a3111ff6e.html)

## Plug Usage (in Phonenix controller)

* router.ex

    ```elixir
    defmodule MyApp.Router do
      pipeline :api do
        plug :accepts, ["json"]
      end

      scope "/wechat", MyApp do
        pipe_through :api

        # validate wechat server config
        get "/", WechatController, :index

        # receive wechat push message
        post "/", WechatController, :create
      end
    end
    ```

* wechat_controller.ex

    ```elixir
    defmodule MyApp.WechatController do
      use MyApp.Web, :controller

      plug Wechat.Plugs.CheckUrlSignature
      plug Wechat.Plugs.CheckMsgSignature when action in [:create]

      def index(conn, %{"echostr" => echostr}) do
        text conn, echostr
      end

      def create(conn, _params) do
        msg = conn.assigns[:msg]
        reply = build_text_reply(msg, msg.content)
        render conn, "text.xml", reply: reply
      end

      defp build_text_reply(%{tousername: to, fromusername: from}, content) do
        %{from: to, to: from, content: content}
      end
    end
    ```

* text.xml.eex

    ```xml
    <xml>
      <MsgType><![CDATA[text]]></MsgType>
      <Content><![CDATA[<%= @reply.content %>]]></Content>
      <ToUserName><![CDATA[<%= @reply.to %>]]></ToUserName>
      <FromUserName><![CDATA[<%= @reply.from %>]]></FromUserName>
      <CreateTime><%= DateTime.to_unix(DateTime.utc_now) %></CreateTime>
    </xml>
    ```
