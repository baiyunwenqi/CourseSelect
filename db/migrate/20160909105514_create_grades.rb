class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.belongs_to :course, index: true
      t.belongs_to :user, index: true
      t.integer :grade
      t.boolean :favorite ,default: false
      t.timestamps null: false
    end
  end
end
