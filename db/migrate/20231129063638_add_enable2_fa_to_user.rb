class AddEnable2FaToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :enable_2fa, :boolean, default: false
  end
end
