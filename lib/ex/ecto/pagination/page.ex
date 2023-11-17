defmodule Ex.Ecto.Pagination.Page do
  @moduledoc """
  Represents a page of paginated results.
  """

  @typedoc false
  @type t(inner_type) :: %Ex.Ecto.Pagination.Page{
    items: [inner_type],
    count: pos_integer,
    total: pos_integer,
    has_previous_page: boolean,
    previous_page_cursor: nil | %{limit: pos_integer, offset: pos_integer},
    has_next_page: boolean,
    next_page_cursor: nil | %{limit: pos_integer, offset: pos_integer}
  }

  @typedoc false
  @type t() :: t(any)

  defstruct items: [],
            count: 0,
            total: 0,
            has_previous_page: false,
            previous_page_cursor: nil,
            has_next_page: false,
            next_page_cursor: nil
end
