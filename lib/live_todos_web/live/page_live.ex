defmodule LiveTodosWeb.PageLive do
  use LiveTodosWeb, :live_view

  alias LiveTodos.Todos

  def mount(_params, _session, socket) do
    {:ok, assign(socket, todos: [], filter: "")}
  end

  def handle_params(_, uri, socket) do
    filter = uri |> String.split("#/") |> Enum.at(1) || "all"
    {:noreply, update_filter(socket, filter)}
  end

  def handle_event("toggle_filter", %{"filter" => filter}, socket) do
    {:noreply, update_filter(socket, filter)}
  end

  def handle_event("add_todo", %{"key" => "Enter", "value" => text}, socket) do
    case Todos.create_todo(%{text: text}) do
      {:ok, _} ->
        {:noreply, update_todos(socket)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("toggle_todo", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)

    case Todos.update_todo(todo, %{complete: !todo.complete}) do
      {:ok, _} ->
        {:noreply, update_todos(socket)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("add_todo", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("destroy_todo", %{"id" => id}, socket) do
    case Todos.delete_by_id(id) do
      {:ok, _} ->
        {:noreply, update_todos(socket)}

      _ ->
        {:noreply, socket}
    end
  end

  defp update_todos(socket), do: update_filter(socket, socket.assigns.filter)

  defp update_filter(socket, filter),
    do: assign(socket, filter: filter, todos: Todos.filter_todos(filter))

  defp filter_class(element, current), do: if(element == current, do: "selected")

  defp all, do: "all"
  defp active, do: "active"
  defp completed, do: "completed"
end
