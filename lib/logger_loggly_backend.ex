defmodule LoggerLogglyBackend do
  use GenEvent

  def init({__MODULE__, name}) do
    {:ok, configure(name, [])}
  end

  def handle_call({:configure, opts}, %{name: name}) do
    {:ok, :ok, configure(name, opts)}
  end

  defp meet_level?(_lvl, nil), do: true
  defp meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end

  def handle_event({_level, gl, _event}, state)
  when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, state) do
    if meet_level?(level, state.level) do
      log_event(level, msg, ts, md, state)
    end
    {:ok, state}
  end

  defp take_metadata(metadata, keys) do
    List.foldr keys, [], fn key, acc ->
      case Keyword.fetch(metadata, key) do
        {:ok, val} -> [{key, val} | acc]
        :error     -> acc
      end
    end
  end

  defp format_event(level, msg, ts, md, %{format: format, metadata: keys}) do
    Logger.Formatter.format(format, level, msg, ts, take_metadata(md, keys))
  end

  defp log_event(level, msg, ts, md, state) do
    output = format_event(level, msg, ts, md, state)
    HTTPoison.post(state.url, output, %{"content-type": "text/plain"}, timeout: state.timeout)
  end

  defp configure(name, opts) do
    env = Application.get_env(:logger, name, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, name, opts)

    format = Keyword.get(opts, :format) |> Logger.Formatter.compile
    level = Keyword.get(opts, :level, :info)
    tags = Keyword.get(opts, :tags, [])
    token = Keyword.get(opts, :token, System.get_env("LOGGLY_TOKEN"))
    type = Keyword.get(opts, :type, :inputs)
    timeout = Keyword.get(opts, :timeout, 5000)
    metadata = Keyword.get(opts, :metadata, [])
    host = Keyword.get(opts, :host, "http://logs-01.loggly.com")

    %{name: name, format: format,
      url: "#{host}/#{type}/#{token}/tag/#{Enum.join(tags, ",")}",
      level: level, metadata: metadata, tags: tags, timeout: timeout}
  end
end
