defmodule NoozoWeb.Admin.Cvs.Children.Components.ExpandCollapse do
  @moduledoc """
  Expanding and collapsing divs
  """
  use NoozoWeb, :surface_func_component

  prop var, :string, required: true

  @impl true
  def render(assigns) do
    ~F"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke="currentColor"
      class="w-5 h-5"
      :class={"{'hidden': #{@var}, 'inline': !#{@var}}"}
    >
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
    </svg>
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke="currentColor"
      class="w-5 h-5"
      :class={"{'inline': #{@var}, 'hidden': !#{@var}}"}
    >
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
    </svg>
    """
  end
end
