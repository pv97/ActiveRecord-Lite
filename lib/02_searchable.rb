require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # ...
    search_clause = params.map do |attr_name,value|
      "#{attr_name} = '#{value}'"
    end.join(" AND ")

    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{search_clause}
    SQL

    results.map { |obj| self.new(obj) }
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
