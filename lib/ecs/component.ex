defmodule ECS.Component do
  @moduledoc """
    A base for creating new Components.
  """

  defstruct [:id, :state]

  @type id :: pid()
  @type component_type :: String.t
  @type state :: map()
  @type t :: %ECS.Component{
    id: id, # Component Agent ID
    state: state
  }

  @callback new(state) :: t # Component interface

  defmacro __using__(_options) do
    quote do
      @behaviour ECS.Component # Require Components to implement interface
    end
  end

  @doc "Create a new agent to keep the state"
  @spec new(component_type, state) :: t
  def new(component_type, initial_state) do
    {:ok, pid} = ECS.Component.Agent.start_link(initial_state)
    ECS.Registry.insert(component_type, pid) # Register component for systems to reference
    %{
      id: pid,
      state: initial_state
    }
  end

  @doc "Retrieves state"
  @spec get(id) :: t
  def get(pid) do
    state = ECS.Component.Agent.get(pid)
    %{
      id: pid,
      state: state
    }
  end

  @doc "Updates state"
  @spec update(id, state) :: t
  def update(pid, new_state) do
    ECS.Component.Agent.set(pid, new_state)
    %{
      id: pid,
      state: new_state
    }
  end
end
