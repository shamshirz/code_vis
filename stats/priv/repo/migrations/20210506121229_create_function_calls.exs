defmodule Stats.Repo.Migrations.CreateFunctionCalls do
  use Ecto.Migration

  def change do
    create table(:function_calls) do
      add :caller_mfa, :string
      add :caller_module, :string
      add :caller_function, :string
      add :caller_arity, :string
      add :target_mfa, :string
      add :target_module, :string
      add :target_function, :string
      add :target_arity, :string

      timestamps()
    end

  end
end
