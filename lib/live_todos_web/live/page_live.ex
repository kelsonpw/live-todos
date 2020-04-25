defmodule LiveTodosWeb.PageLive do
  use LiveTodosWeb, :live_view

  alias LiveTodos.Todos

  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       todos: [],
       filter: "",
       editing: "",
       all_toggle: false
     )}
  end

  def handle_params(_, uri, socket) do
    filter = uri |> String.split("#/") |> Enum.at(1) || "all"
    {:noreply, update_filter(socket, filter)}
  end

  def handle_event("toggle_filter", %{"filter" => filter}, socket) do
    {:noreply, update_filter(socket, filter)}
  end

  def handle_event("toggle_all_todos", _params, socket) do
    complete = not socket.assigns.all_toggle
    Todos.toggle_all_todos(%{complete: complete})
    {:noreply, update_todos(socket) |> assign(editing: "", all_toggle: complete)}
  end

  def handle_event("add_todo", %{"key" => "Enter", "value" => text}, socket) do
    case Todos.create_todo(%{text: text}) do
      {:ok, _} ->
        {:noreply, update_todos(socket)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("add_todo", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("edit_todo", %{"key" => "Enter", "id" => id, "value" => text}, socket),
    do: handle_edit(socket, %{id: id, text: text})

  def handle_event("edit_todo", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("edit_todo_blur", %{"id" => id, "value" => text}, socket),
    do: handle_edit(socket, %{id: id, text: text})

  def handle_event("toggle_todo", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)

    case todo |> Todos.update_todo(%{complete: !todo.complete}) do
      {:ok, _} ->
        {:noreply, update_todos(socket)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("toggle_editing", %{"id" => id}, socket) do
    {:noreply, assign(socket, editing: id)}
  end

  def handle_event("destroy_todo", %{"id" => id}, socket) do
    case Todos.delete_by_id(id) do
      {:ok, _} ->
        {:noreply, update_todos(socket)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("destroy_completed", _, socket) do
    case Todos.delete_completed() do
      nil ->
        {:noreply, socket}

      _ ->
        {:noreply, update_todos(socket)}
    end
  end

  defp handle_edit(socket, %{id: id, text: text}) do
    case id
         |> Todos.get_todo!()
         |> Todos.update_todo(%{text: text}) do
      {:ok, _} ->
        {:noreply, update_todos(socket) |> assign(editing: "")}

      _ ->
        {:noreply, socket}
    end
  end

  defp update_todos(socket), do: update_filter(socket, socket.assigns.filter)

  defp update_filter(socket, filter),
    do: assign(socket, filter: filter, todos: Todos.filter_todos(filter))

  defp filter_class("all", ""), do: "selected"
  defp filter_class(mode, mode), do: "selected"
  defp filter_class(_, __), do: ""

  defp all, do: "all"
  defp active, do: "active"
  defp completed, do: "completed"

  defp todo_item_class(%{complete: true}, _), do: "completed"

  defp todo_item_class(%{complete: false, id: id}, current),
    do: if(Integer.to_string(id) == current, do: "editing")

  defp items_remaining(todos) do
    count =
      todos
      |> Enum.filter(&(not &1.complete))
      |> Enum.count()

    "<strong>#{count}</strong> #{if count != 1, do: "items", else: "item"} left"
  end

  defp show_todos?(_todos, "active"), do: true
  defp show_todos?(_todos, "completed"), do: true
  defp show_todos?(todos, _), do: Enum.count(todos) > 0
end
