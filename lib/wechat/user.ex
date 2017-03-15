defmodule Wechat.User do
  @moduledoc """
  User API.
  """

  import Wechat.ApiBase

  def list(config_data) do
    get config_data, "user/get"
  end

  def list(config_data, next_openid) do
    get config_data, "user/get", next_openid: next_openid
  end

  def info(config_data, openid) do
    get config_data, "user/info", openid: openid
  end
end
