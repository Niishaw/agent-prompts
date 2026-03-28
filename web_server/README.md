# Elixir Markdown Server

A simple Elixir Plug application to serve the agent markdown files locally.

## Prerequisites

You need to have Elixir installed on your machine.
- **Windows**: Install via [Scoop](https://scoop.sh/): `scoop install elixir`, or download the installer from [elixir-lang.org](https://elixir-lang.org/install.html#windows).
- **macOS**: `brew install elixir`
- **Linux**: `apt-get install elixir` (or your distribution's package manager)

## Running the Server

1. Open your terminal in this `web_server` directory.
2. Fetch the dependencies:
   ```bash
   mix deps.get
   ```
3. Start the server:
   ```bash
   mix run --no-halt
   ```
4. Open your browser and navigate to [http://localhost:4000](http://localhost:4000)

## How it works

- It uses `Plug.Cowboy` to run a local HTTP server on port 4000.
- It uses `Earmark` to convert `.md` files to HTML on the fly.
- It automatically serves the `README.md` from the parent directory as the index page.
- It intercepts any requests for `.md` files in the parent directory, renders them as HTML, and applies some basic styling so they look good in the browser.
