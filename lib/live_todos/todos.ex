defmodule LiveTodos.Todos do
  import Ecto.Query, warn: false
  alias LiveTodos.Repo

  alias LiveTodos.Todos.Todo

  def list_todos do
    Todo
    |> order_by(asc: :id)
    |> Repo.all()
  end

  def filter_todos("active") do
    from(t in Todo,
      where: not t.complete,
      order_by: t.id
    )
    |> Repo.all()
  end

  def filter_todos("completed") do
    from(t in Todo,
      where: t.complete,
      order_by: t.id
    )
    |> Repo.all()
  end

  def filter_todos(_), do: list_todos()

  def get_todo!(id), do: Repo.get!(Todo, id)

  def create_todo(attrs \\ %{}) do
    %Todo{}
    |> Todo.changeset(attrs)
    |> Repo.insert()
  end

  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  def toggle_all_todos(%{complete: complete}) do
    Repo.update_all(Todo,
      set: [complete: complete]
    )
  end

  def delete_todo(%Todo{} = todo) do
    Repo.delete(todo)
  end

  def delete_completed do
    from(t in Todo, where: t.complete) |> Repo.delete_all()
  end

  def delete_by_id(id) do
    id
    |> get_todo!()
    |> delete_todo()
  end

  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end
end
