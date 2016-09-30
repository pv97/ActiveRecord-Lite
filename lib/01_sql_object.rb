require_relative 'db_connection'
require 'active_support/inflector'
require_relative '02_searchable'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    # ...
    if @columns.nil?
      database_array = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{table_name}
      SQL

      @columns = database_array[0].map {|el| el.to_sym}
    end
    @columns
  end

  def self.finalize!
    columns.each do |column|
      define_method("#{column}") do
        attributes[column]
      end

      define_method("#{column}=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
    # ...
    @table_name = self.to_s.tableize if @table_name.nil?
    @table_name
  end

  def self.all
    # ...
    rows = self.to_s.tableize
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    # ...
    container = []
    results.each do |obj|
      new_obj = self.new(obj)
      container << new_obj
    end

    container
  end

  def self.find(id)
    # ...
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = #{id}
    SQL
    unless results.empty?
      self.new(results[0])
    else
      nil
    end
  end

  def initialize(params = {})
    # ...
    # p columns

    params.each do |attr_name,value|
      column = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(column)
      send("#{attr_name}=".to_sym, value)
    end
  end

  def attributes
    # ...
    @attributes ||= {}
    @attributes
  end

  def attribute_values
    # ...
    self.class.columns.map do |col_name|
      send(col_name)
    end
  end

  def insert
    # ...
    cols = self.class.columns.join(",")
    question_marks = (["?"] * self.class.columns.count).join(",")
    p cols
    p question_marks
    DBConnection.execute(<<-SQL,*attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{cols})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
    columns = self.class.columns
    attributes = attribute_values

    i = 1
    insert_vals = []

    while i < columns.length
      insert_vals << "#{columns[i]} = '#{attributes[i]}'"
      i+= 1
    end

    DBConnection.execute(<<-SQL)
      UPDATE
        #{self.class.table_name}
      SET
        #{insert_vals.join(",")}
      WHERE
        id = #{id}
    SQL
  end

  def save
    # ...
    if id.nil?
      insert
    else
      update
    end
  end

end
