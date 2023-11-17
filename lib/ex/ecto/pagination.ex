defmodule Ex.Ecto.Pagination do
  @moduledoc """
  Pagination helper functions.
  """

  @typedoc false
  @type pagination_control_option :: {:limit, pos_integer} | {:offset, pos_integer}

  @typedoc false
  @type pagination_control :: [pagination_control_option]

  import Ecto.Query
  import Keyword, only: [get: 2]

  alias Ex.Ecto.Pagination.Page

  @doc """
  Returns a page of paginated results for a query.
  """
  @spec paginate(repo :: module, query :: Ecto.Query.t(), pagination_control()) ::
          Ex.Ecto.Pagination.Page.t(any())

  def paginate(repo, query, pagination_control) do
    limit = get(pagination_control, :limit)
    offset = get(pagination_control, :offset) || 0

    results =
      query
      |> maybe_limit(limit)
      |> maybe_offset(offset)
      |> repo.all()

    count = length(results)
    total = count_query(query) |> repo.one()

    previous_page =
      case not is_nil(limit) and offset > 0 do
        true -> %{limit: limit, offset: offset - limit}
        false -> nil
      end

    next_page =
      case not is_nil(limit) and count + offset < total do
        true -> %{limit: limit, offset: offset + limit}
        false -> nil
      end

    %Page{
      items: results,
      count: count,
      total: total,
      has_previous_page: not is_nil(previous_page),
      previous_page_cursor: previous_page,
      has_next_page: not is_nil(next_page),
      next_page_cursor: next_page
    }
  end

  defp maybe_limit(query, nil), do: query
  defp maybe_limit(query, limit), do: limit(query, ^limit)

  defp maybe_offset(query, offset), do: offset(query, ^offset)

  defp count_query(query) do
    from _ in exclude(exclude(query, :order_by), :select),
      select: count(fragment("1"))
  end
end
