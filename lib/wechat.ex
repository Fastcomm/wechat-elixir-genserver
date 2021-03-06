defmodule Wechat do
  @moduledoc """
  Assemble config and provide access to access_token.
  """
  use GenServer
  require Logger

  @spec start_link(binary(), Wechat.ConfigData) :: any()
  def start_link(name, config_data, register_global \\ false) do
      Logger.info "Start wechat lib genserver, name: #{name}"
      if register_global do
        GenServer.start_link(__MODULE__, config_data, name: {:global, name})
      else
        GenServer.start_link(__MODULE__, config_data , name: String.to_atom("#{name}"))
      end
  end

  def send_text_message(pid, user_open_id, message) do
    GenServer.cast(pid, {:send_text_message, user_open_id, message})
  end

  def send_news_message(pid, user_open_id, type, url) do
    GenServer.cast(pid, {:send_news_message, {user_open_id, type, url}})
  end

  def send_image_message(pid, media_id) do
    GenServer.cast(pid, {:send_image_message, media_id})
  end

  def user_info(pid, user_open_id) do
    GenServer.call(pid, {:user_info, user_open_id})
  end

  def download_file(pid, media_id) do
    GenServer.call(pid, {:download_file, media_id})
  end

  def force_refresh_access_token(pid) do
    GenServer.call(pid, {:force_refresh_access_token})
  end

  def handle_call({:force_refresh_access_token}, from, config_data) do
     access_token = Wechat.refresh_access_token(config_data)
     {:reply, access_token, config_data}
  end

  def handle_call({:user_info, user_open_id}, from, config_data) do
    result = Wechat.User.info(config_data, user_open_id)
    {:reply, result, config_data}
  end

  def handle_cast({:send_text_message, user_open_id, message}, config_data) do
    Wechat.Message.Custom.send_text(config_data, user_open_id, message)
    {:noreply, config_data}
  end

  def handle_cast({:send_image_message, user_open_id, media_id}, config_data) do
    Wechat.Message.Custom.send_image(config_data, user_open_id, media_id)
    {:noreply, config_data}
  end

  def handle_cast({:send_news_message, {user_open_id, type, url}}, config_data) do
    Wechat.Message.Custom.send_mpnews(config_data, user_open_id, type, url)
    {:noreply, config_data}
  end

  def handle_call({:download_file, media_id}, from, config_data ) do
    access_token = access_token(config_data)
    Logger.info "access_token: #{inspect access_token}"
    mediafile = Wechat.Media.download(access_token, media_id)
    {:reply, mediafile, config_data}
  end

  @spec config(Wechat.ConfigData) :: any()
  def config(config_data) do
    [appid: config_data.appid, secret: config_data.secret, token: config_data.token, encoding_aes_key: config_data.encoding_aes_key, token_file: config_data.token_file]
  end

  def access_token(config_data) do
    token_info = read_token_from_file(config_data)
    token_info =
      case access_token_expired?(token_info) do
        true -> refresh_access_token(config_data)
        false -> token_info
      end
   token_info.access_token
  end

  def refresh_access_token(config_data) do
    now = DateTime.to_unix(DateTime.utc_now)
    new_token = Wechat.AccessToken.token(config_data)
    token_info = Map.merge(new_token, %{refreshed_at: now})
    File.write(config_data.token_file, Poison.encode!(token_info))
    token_info
  end

  defp read_token_from_file(config_data) do
    case File.read(config_data.token_file) do
      {:ok, binary} -> Poison.decode!(binary, keys: :atoms)
      {:error, _reason} -> refresh_access_token(config_data)
    end
  end

  defp access_token_expired?(token_info) do
    if Map.has_key?(token_info, :expires_in) do
    now = DateTime.utc_now |> DateTime.to_unix
    now >= (token_info.refreshed_at + token_info.expires_in)
    else
      true
    end
  end
end







