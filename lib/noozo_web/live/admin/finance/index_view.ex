defmodule NoozoWeb.Admin.Finance.IndexView do
  use NoozoWeb, :surface_view

  alias Noozo.Finance
  alias Noozo.Pagination

  defmodule Line do
    @keys ~w(date description debit credit balance category)a
    @enforce_keys @keys
    @type t() :: %__MODULE__{
            date: Date.t(),
            description: String.t(),
            debit: float(),
            credit: float(),
            balance: float(),
            category: String.t()
          }
    defstruct @keys

    def new(csv_line) do
      [
        date_from,
        _date_to,
        description,
        debit,
        credit,
        balance,
        _account_balance,
        category | _rest
      ] = String.split(csv_line, ";")

      %Line{
        date: date_from |> Timex.parse!("{D}-{0M}-{YYYY}") |> Timex.to_date(),
        description: description,
        debit: parse_value(debit),
        credit: parse_value(credit),
        balance: parse_value(balance),
        category: category
      }
    end

    defp parse_value(""), do: Money.new(0, :EUR)

    defp parse_value(string) do
      string
      |> String.replace("\.", "")
      |> String.replace("\,", ".")
      |> String.to_float()
      |> (&(&1 * 100)).()
      |> trunc()
      |> Money.new(:EUR)
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:csv,
       accept: ~w(.csv),
       max_entries: 1,
       max_file_size: 5_000_000
     )}
  end

  @impl true
  def handle_params(params, _session, socket) do
    start_date =
      params["start_date"] ||
        Timex.today() |> Timex.shift(years: -2) |> Timex.format!("{YYYY}-{0M}-{D}")

    end_date = params["end_date"] || Timex.today() |> Timex.format!("{YYYY}-{0M}-{D}")

    params =
      params
      |> Map.put("start_date", start_date)
      |> Map.put("end_date", end_date)

    page_movements = Finance.list_bank_account_movements(params)
    movements = Finance.list_bank_account_movements(params, false)

    {debits, credits} = Finance.get_debit_credits(params)

    {:noreply,
     socket
     |> assign(:page_movements, page_movements)
     |> assign(:movements, movements)
     |> assign(:params, params)
     |> assign(:debits, Money.new(debits || 0, :EUR))
     |> assign(:credits, Money.new(credits || 0, :EUR))}
  end

  @impl true
  def render(assigns) do
    ~F"""
    <div class="text-lg mb-6 font-medium">Finances</div>

    <form phx-change="update-dates">
      <input type="date" name="start_date" max={Timex.today()} value={@params["start_date"]}>
      <input type="date" name="end_date" max={Timex.today()} value={@params["end_date"]}>
    </form>
    <table>
      <thead>
        <tr>
          <th>Date</th>
          <th>Description</th>
          <th>Debit</th>
          <th>Credit</th>
          <th>Balance</th>
          <th>Category</th>
        </tr>
      </thead>
      <tbody>
        {#for entry <- @page_movements}
          <tr>
            <td>{entry.date}</td>
            <td>{entry.description}</td>
            <td>{entry.debit}</td>
            <td>{entry.credit}</td>
            <td>{entry.balance}</td>
            <td>{entry.category}</td>
          </tr>
        {/for}
        <tr>
          <td />
          <td />
          <td>{@debits}</td>
          <td>{@credits}</td>
          <td />
          <td />
        </tr>
      </tbody>
    </table>
    <Pagination source_assigns={assigns} entries={@page_movements} module={__MODULE__} />

    <div
      id="finance-diagram"
      phx-hook="FinanceDiagram"
      data-finance-data={serialize(@movements)}
      class="mt-6 h-64"
    />

    <div class="text-lg font-medium mt-10 mb-6">Upload movements</div>

    <form phx-submit="upload" phx-change="validate">
      <div class="col-span-6">
        {#for {_ref, msg} <- @uploads.csv.errors}
          <div class="flex-none p-2">
            <p class="shadow p-5 bg-red-300 rounded-md" role="alert">
              {Phoenix.Naming.humanize(msg)}
            </p>
          </div>
        {/for}

        <div class="flex">
          {live_file_input(@uploads.csv)}
          <input
            class="btn flex-col cursor-pointer"
            type="submit"
            value="Upload" />
        </div>
      </div>
    </form>

    {#for entry <- @uploads.csv.entries}
      <div class="col-span-6">
        <div class="flex-col">
          {entry.client_name}
        </div>
        <div class="flex-col">
          <progress max="100" value={entry.progress} />
        </div>
        <div class="flex-col">
          <div class="btn cursor-pointer inline" phx-click="cancel-entry" phx-value-ref={entry.ref}>
            cancel
          </div>
        </div>
      </div>
    {/for}
    """
  end

  @impl true
  def handle_event(
        "update-dates",
        %{"start_date" => start_date, "end_date" => end_date} = _event,
        socket
      ) do
    params =
      socket.assigns.params
      |> Map.delete("page")
      |> Map.put("start_date", start_date)
      |> Map.put("end_date", end_date)

    {:noreply,
     push_redirect(socket,
       to: Routes.live_path(socket, __MODULE__, params)
     )}
  end

  @impl true
  def handle_event("upload", _event, socket) do
    # Remove header lines
    [
      _title,
      _empty_line,
      _account,
      _start_date,
      _end_date,
      _empty_line2,
      _headers
      | data
    ] =
      socket
      |> consume_file()
      |> binary_to_string()
      |> String.split("\r\n")

    # Remove footer lines
    [_footer1, _footer2 | data] = Enum.reverse(data)

    # Convert to lines
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    maps =
      data
      |> Enum.map(fn csv_line ->
        csv_line
        |> Line.new()
        |> Map.from_struct()
        |> Map.put(:inserted_at, now)
        |> Map.put(:updated_at, now)
      end)

    {count, nil} = Finance.create_bank_account_movements(maps)

    {:noreply, assign(socket, info: "File uploaded. #{count} records added/updated.")}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :csv, ref)}
  end

  # sobelow_skip ["Traversal.FileModule"]
  defp consume_file(socket) do
    [{binary_data, _type}] =
      consume_uploaded_entries(socket, :csv, fn meta, entry ->
        {File.read!(meta.path), entry.client_type}
      end)

    binary_data
  end

  defp binary_to_string(raw) do
    codepoints = String.codepoints(raw)

    Enum.reduce(
      codepoints,
      fn w, result ->
        if String.valid?(w) do
          result <> w
        else
          <<parsed::8>> = w
          result <> <<parsed::utf8>>
        end
      end
    )
  end

  defp serialize(movements) do
    movements
    |> Enum.map(&Map.take(&1, [:date, :balance]))
    |> sort(:month)
    |> Enum.map(fn {date, movements} ->
      value =
        case movements do
          [] -> 0
          [entry] -> entry.balance.amount / 100.0
          [entry | _rest] -> entry.balance.amount / 100.0
        end

      {date, value}
    end)
    |> Map.new()
    |> Jason.encode!()
  end

  defp sort(data, :day) do
    data
    |> Enum.sort_by(&Map.get(&1, :date), &<=/2)
    |> Enum.group_by(&Map.get(&1, :date))
  end

  defp sort(data, :week) do
    data
    |> Enum.sort_by(&(&1 |> Map.get(:date) |> Timex.format!("{YYYY}-{0Wiso}")), &<=/2)
    |> Enum.group_by(&(&1 |> Map.get(:date) |> Timex.format!("{YYYY}-{0Wiso}")))
  end

  defp sort(data, :month) do
    data
    |> Enum.sort_by(&(&1 |> Map.get(:date) |> Timex.format!("{YYYY}-{0M}")), &<=/2)
    |> Enum.group_by(&(&1 |> Map.get(:date) |> Timex.format!("{YYYY}-{0M}")))
  end

  defp sort(data, :year) do
    data
    |> Enum.sort_by(&(&1 |> Map.get(:date) |> Timex.format!("{YYYY}")), &<=/2)
    |> Enum.group_by(&(&1 |> Map.get(:date) |> Timex.format!("{YYYY}")))
  end
end
