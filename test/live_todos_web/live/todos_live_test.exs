defmodule LiveTodosWeb.TodosLiveTest do
  use LiveTodosWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, todos_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome to Phoenix!"
    assert render(todos_live) =~ "Welcome to Phoenix!"
  end
end
