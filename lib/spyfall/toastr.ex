defmodule Spyfall.Toastr do
  @moduledoc "Formats and outputs error messages for all types using toastr"
  use Phoenix.HTML
  import SpyfallWeb.ErrorHelpers

  @doc """
    Makes appropriate error message for changeset error messages for changeset errors
    Usage: In controller `put_flash(:changeset, changeset.errors)`
  """

  def make_msg("changeset", error) do
    get_errors_from_changeset(error)
  end

  @doc "Makes appropriate error message for toastr messages, for error success info warning "
  def make_msg(key, msg) when key in ~w(error success info warning) do
    content_tag(:script, toastr_msg(msg, key))
  end

  @doc "If the flash doesn't match anything return empty string"
  def make_msg(_, _) do
    ""
  end

  # takes errors from changeset and wraps each in script tag for toastr
  defp get_errors_from_changeset(errors) do
    errors
    |> Enum.map(fn {error_attribute, error_message} ->
      content_tag(
        :script,
        error_attribute
        |> get_each_error(error_message)
        |> toastr_msg("error", "top-right")
      )
    end)
  end

  # formats each changeset error message
  defp get_each_error(error_attribute, error_message) do
    (humanize(error_attribute) <> " " <> translate_error(error_message))
    |> html_escape()
    |> safe_to_string()
  end

  # sets up default position for toastr_msg function
  defp toastr_msg(
         msg,
         type,
         options \\ "'positionClass': 'toast-top-center', 'closeButton': false"
       )

  # builds toastr message for notifications -- top right
  defp toastr_msg(msg, type, "top-right") do
    """
      window.toastr.options = {
        'positionClass': 'toast-top-right',
        'closeButton': false
        };
      window.toastr.#{type}('#{msg}')
    """
    |> raw()
  end

  # builds toastr message for notifications -- default position
  defp toastr_msg(msg, type, options) do
    """
      window.toastr.options = {
        #{options}
      };
      window.toastr.#{type}('#{msg}')
    """
    |> raw()
  end
end
