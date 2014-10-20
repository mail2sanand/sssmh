module MigrationHelpers
  def foreign_key(from_table, from_column, to_table,to_column="id")
    constraint_name = "fk_#{from_table}_#{from_column}" 

    execute %{alter table #{from_table}
              add constraint #{constraint_name}
              foreign key (#{from_column})
              references #{to_table}(#{to_column.to_sym}) }
  end
  
  def drop_foreign_key(to_table,fk_name)
    execute %{ALTER TABLE #{to_table} DROP FOREIGN KEY `#{fk_name}`}
    execute %{DROP INDEX #{fk_name} ON #{to_table}}
  end
end
