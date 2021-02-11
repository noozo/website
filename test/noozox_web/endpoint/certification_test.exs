defmodule NoozoWeb.Endpoint.CertificationTest do
  use ExUnit.Case, async: false
  import SiteEncrypt.Phoenix.Test

  test "certification" do
    # clean_restart(NoozoWeb.Endpoint)
    cert = get_cert(NoozoWeb.Endpoint)

    assert cert.domains ==
             ~w/pedroassuncao.com www.pedroassuncao.com cv.pedroassuncao.com resume.pedroassuncao.com/
  end
end
