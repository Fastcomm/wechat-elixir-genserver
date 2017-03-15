defmodule Wechat.Media do
  @moduledoc """
  Media API. Only provide download at the moment.
  """

  import Wechat.ApiFile

  def download(access_token, media_id) do
    get "media/get", %{media_id: media_id , access_token: access_token}
  end
end
