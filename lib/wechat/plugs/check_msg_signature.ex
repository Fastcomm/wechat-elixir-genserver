defmodule Wechat.Plugs.CheckMsgSignature do
  @moduledoc """
  Plug to parse xml message.
  """

  import Plug.Conn
  import Wechat.MsgParser
  import Wechat.Signature
  import Wechat.Cipher

  def init(opts) do
    encoding_aes_key = Application.get_env(:wechat, Wechat)[:encoding_aes_key]
    Keyword.merge(opts, aes_key: aes_key(encoding_aes_key))
  end

  defp aes_key(nil) do
    nil
  end
  defp aes_key(encoding_aes_key) do
    encoding_aes_key <> "=" |> Base.decode64!
  end

  def call(conn, opts) do
    {:ok, xml, conn} = read_body(conn)
    msg = xml |> parse
    case msg_encrypted?(conn.params) do
      true -> decrypt_msg(conn, msg, opts)
      false -> conn |> assign(:msg, msg)
    end
  end

  defp decrypt_msg(conn, %{encrypt: msg_encrypt}, opts) do
    aes_key = Keyword.fetch!(opts, :aes_key)
    {appid, msg_decrypt} =  decrypt(msg_encrypt, aes_key)
    conn |> assign(:msg, msg_decrypt |> parse)
  end

  defp msg_encrypted?(params) do
    encrypt_type = Map.get(params, "encrypt_type")
    encrypt_type in [nil, "raw"] == false
  end

end
