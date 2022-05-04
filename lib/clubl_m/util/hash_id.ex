defmodule HashId do
  @coder Hashids.new(
           salt: System.get_env("SECRET_KEY_BASE") || "xxx",
           min_len: 10
         )

  def encode(id) do
    Hashids.encode(@coder, id)
  end

  def decode(data) do
    List.first(Hashids.decode!(@coder, data))
  end
end
