require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_query = params.keys.map{ |para_name| "#{para_name} = ?" }
    records = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_query.join(" AND ")}
    SQL
    self.parse_all(records)
  end
end

class SQLObject
  extend Searchable
end
