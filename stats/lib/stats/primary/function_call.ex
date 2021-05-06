defmodule Stats.Primary.FunctionCall do
  use Ecto.Schema
  import Ecto.Changeset

  schema "function_calls" do
    field :caller_arity, :string
    field :caller_function, :string
    field :caller_mfa, :string
    field :caller_module, :string
    field :target_arity, :string
    field :target_function, :string
    field :target_mfa, :string
    field :target_module, :string

    timestamps()
  end

  @doc false
  def changeset(function_call, attrs) do
    function_call
    |> cast(attrs, [:caller_mfa, :caller_module, :caller_function, :caller_arity, :target_mfa, :target_module, :target_function, :target_arity])
    |> validate_required([:caller_mfa, :caller_module, :caller_function, :caller_arity, :target_mfa, :target_module, :target_function, :target_arity])
  end
end
