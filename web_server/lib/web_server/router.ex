defmodule WebServer.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  defp base_dir do
    # Serves the parent directory (agency-agents)
    Path.expand("..", File.cwd!())
  end

  get "/" do
    render_readme(conn)
  end

  get "/*path" do
    base_dir = base_dir()
    file_path = Path.join([base_dir] ++ path)

    # Prevent directory traversal attacks
    expanded_path = Path.expand(file_path)
    if within_base_dir?(expanded_path, base_dir) and File.regular?(expanded_path) do
      if String.ends_with?(expanded_path, ".md") do
        render_markdown(conn, expanded_path)
      else
        send_file(conn, 200, expanded_path)
      end
    else
      send_resp(conn, 404, "Not found")
    end
  end

  defp within_base_dir?(path, base_dir) do
    path_expanded = Path.expand(path)
    base_expanded = Path.expand(base_dir)
    base_with_sep = String.trim_trailing(base_expanded, "/") <> "/"

    path_expanded == base_expanded or String.starts_with?(path_expanded, base_with_sep)
  end

  defp render_readme(conn) do
    readme_path = Path.join(base_dir(), "README.md")
    if File.exists?(readme_path) do
      render_markdown(conn, readme_path)
    else
      send_resp(conn, 404, "README.md not found")
    end
  end

  defp render_markdown(conn, file_path) do
    content = File.read!(file_path)
    case Earmark.as_html(content) do
      {:ok, html_doc, _dep_messages} ->
        html = wrap_html(html_doc, Path.basename(file_path))
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, html)
      {:error, _html_doc, _error_messages} ->
        send_resp(conn, 500, "Error rendering markdown")
    end
  end

  defp wrap_html(content, title) do
    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>#{title}</title>
      <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; line-height: 1.6; padding: 2rem; max-width: 900px; margin: 0 auto; color: #333; }
        pre { background: #f6f8fa; padding: 16px; overflow: auto; border-radius: 6px; font-size: 14px; }
        code { background: rgba(27,31,35,0.05); padding: 0.2em 0.4em; border-radius: 3px; font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, "Liberation Mono", monospace; font-size: 85%; }
        pre code { background: transparent; padding: 0; font-size: 100%; }
        a { color: #0366d6; text-decoration: none; }
        a:hover { text-decoration: underline; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 1rem; }
        th, td { border: 1px solid #dfe2e5; padding: 6px 13px; }
        th { background-color: #f6f8fa; font-weight: 600; }
        tr:nth-child(2n) { background-color: #f6f8fa; }
        blockquote { padding: 0 1em; color: #6a737d; border-left: 0.25em solid #dfe2e5; margin: 0 0 16px 0; }
        img { max-width: 100%; }
      </style>
    </head>
    <body>
      <nav style="margin-bottom: 2rem; padding-bottom: 1rem; border-bottom: 1px solid #eaeaea;">
        <a href="/">← Back to README</a>
      </nav>
      #{content}
    </body>
    </html>
    """
  end
end
