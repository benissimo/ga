class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.string :title
      t.string :author
      t.string :publisher
      t.smallint :pages
      t.decimal :price
      t.text :description
      t.int :category
      t.string :subcategory
      t.int :special_offer
      t.int :discount
      t.string :source
      t.string :isbn

      t.timestamps
    end
  end

  def self.down
    drop_table :books
  end
end
