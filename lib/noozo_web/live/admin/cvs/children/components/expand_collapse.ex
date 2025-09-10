defmodule NoozoWeb.Admin.Cvs.Children.Components.ExpandCollapse do
  @moduledoc """
  Expanding and collapsing divs
  """
  use Phoenix.Component

  attr :var, :string, required: true

  def render(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke="currentColor"
      class={if @var == "true", do: "w-5 h-5 hidden", else: "w-5 h-5 inline" }>
    >
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
    </svg>
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      stroke="currentColor"
      class={if @var == "true", do: "w-5 h-5 inline", else: "w-5 h-5 hidden" }>
    >
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
    </svg>
    """
  end
end
