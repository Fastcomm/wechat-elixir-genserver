defmodule Wechat.Cipher do
  @moduledoc """
  Decrypt wechat msg.
  """
  	require Logger

  # def decrypt(msg_encrypt, aes_key) do
  #   Logger.warn "msg_encrypt: #{msg_encrypt}"
  #   plain_text =
  #     msg_encrypt
  #     |> Base.url_decode64!
  #     |> Cipher.decrypt

  #   # http://mp.weixin.qq.com/wiki/2/3478f69c0d0bbe8deb48d66a3111ff6e.html
  #   # random(16B) + msg_len(4B) + msg + appid
  #   # <<_ :: binary-size(16),
  #   #   msg_len :: integer-size(32),
  #   #   msg :: binary-size(msg_len),
  #   #   appid :: binary>> = plain_text
  #   Logger.warn "plain_text: #{plain_text}"
  #   {"80890", plain_text}
  # end

 def decrypt(msg_encrypt, aes_key) do
    Logger.warn "msg_encrypt: #{msg_encrypt}"
    decoded_msg =  msg_encrypt |> Base.decode64!

    Logger.warn "decoded_msg: #{inspect decoded_msg}"
       decrypted_msg = decoded_msg |> decrypt_aes(aes_key)

    Logger.warn "decrypted_msg: #{inspect decrypted_msg}"
      plain_text = decrypted_msg |> decode_padding

    Logger.warn "plain_text: #{plain_text}"

    # http://mp.weixin.qq.com/wiki/2/3478f69c0d0bbe8deb48d66a3111ff6e.html
    # random(16B) + msg_len(4B) + msg + appid
    <<_ :: binary-size(16),
      msg_len :: integer-size(32),
      msg :: binary-size(msg_len),
      appid :: binary>> = plain_text

    {appid, msg}
  end

  defp decrypt_aes(aes_encrypt, aes_key) do
    iv = binary_part(aes_key, 0, 16)
    :crypto.block_decrypt(:aes_cbc, aes_key, iv, aes_encrypt)
  end

  defp decode_padding(padded_text) do
    len = byte_size(padded_text)
    <<pad :: utf8>> = binary_part(padded_text, len, -1)
    case pad < 1 or pad > 32 do
      true -> binary_part(padded_text, 0, len)
      false -> binary_part(padded_text, 0, len-pad)
    end
  end
end
