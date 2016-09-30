require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    # ...

    define_method(name) do

      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      first_table = self.class.table_name
      second_table = through_options.class_name.constantize.table_name
      third_table = source_options.class_name.constantize.table_name

      first_primary_key = through_options.primary_key
      second_primary_key = source_options.primary_key

      first_foreign_key = through_options.foreign_key
      second_foreign_key = source_options.foreign_key

      results = DBConnection.execute(<<-SQL)
        SELECT
          #{third_table}.*
        FROM
          #{first_table}
        JOIN
          #{second_table}
        ON
          #{first_table}.#{first_foreign_key} = #{second_table}.#{second_primary_key}
        JOIN
          #{third_table}
        ON
          #{second_table}.#{second_foreign_key} = #{third_table}.id
        WHERE
          #{first_table}.#{first_primary_key} = #{id}
      SQL

      source_options.class_name.constantize.parse_all(results).first
    end
  end
end
