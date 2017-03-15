defmodule Wechat.AccessToken do
  @moduledoc """
  AccessToken API.
  """

  import Wechat.ApiBase

  def token(config_data) do
    get config_data, "token",
      [ grant_type: "client_credential",
      appid: config_data.appid,
      secret: config_data.secret ]
  end
end
