defmodule NoozoWeb.PDFGenerationController do
  @moduledoc """
  Controller responsible for generating pdf versions of documents
  """
  use NoozoWeb, :controller
  plug Ueberauth

  if Mix.env() == :test do
    def page(conn, %{"slug" => slug} = _params) do
      conn
      |> put_resp_content_type("text/pdf")
      |> put_resp_header("content-disposition", "attachment; filename=\"#{slug}.pdf\"")
      |> put_resp_header("content-type", "application/pdf")
      |> send_resp(200, "<html><body style=\"font-size: 32pt;\">Fake PDF</body></html>")
    end
  else
    def page(conn, %{"slug" => slug} = params) do
      page = Noozo.Core.get_page_by_slug(params["slug"])

      {:ok, binary} = maybe_generate_pdf(page, params["force"])

      return_pdf(conn, slug, binary)
    end

    defp return_pdf(conn, title, content) do
      conn
      |> put_resp_content_type("text/pdf")
      |> put_resp_header("content-disposition", "attachment; filename=\"#{title}.pdf\"")
      |> put_resp_header("content-type", "application/pdf")
      |> send_resp(200, "<body style=\"font-size: 32pt;\">#{content}</body></html>")
    end
  end

  # sobelow_skip ["Traversal.FileModule"]
  defp maybe_generate_pdf(page, force) do
    tmp_file = Path.join("/tmp", page.slug <> ".pdf")

    if File.exists?(tmp_file) do
      modified_time = File.stat!(tmp_file).mtime
      modified_time = Timex.to_datetime(modified_time, "Etc/UTC")
      time_since_creation = Timex.diff(DateTime.utc_now(), modified_time, :hours)

      if time_since_creation > 24 or force do
        {:ok, generate_pdf(page, tmp_file)}
      else
        {:ok, File.read!(tmp_file)}
      end
    else
      {:ok, generate_pdf(page, tmp_file)}
    end
  end

  # sobelow_skip ["Traversal.FileModule"]
  def generate_pdf(page, file) do
    images_dir = "file://" <> to_string(:code.priv_dir(:noozo)) <> "/static/images"

    content =
      page.content
      |> String.replace("https://pedroassuncao.com/images", images_dir)
      |> String.replace("https://www.pedroassuncao.com/images", images_dir)
      |> String.replace("http://pedroassuncao.com/images", images_dir)
      |> String.replace("http://www.pedroassuncao.com/images", images_dir)

    css_dir = to_string(:code.priv_dir(:noozo)) <> "/static/css/"

    content = """
      <html>
        <head>
        <link rel="stylesheet" type="text/css" href="#{css_dir}/app.css" />
        </head>
        <body>
          <section class="section">
            <div class="container">
              #{content}
            </div>
          </section>
        </body>
      </html>
    """

    pdf_binary =
      PdfGenerator.generate_binary!(
        content,
        prefer_system_executable: true,
        page_size: "A4",
        shell_params: ["--dpi", "400"]
      )

    File.write!(file, pdf_binary)

    pdf_binary
  end
end
