class AddOpenAttribute < ActiveRecord::Migration
  def change
    add_column :courses,:open,:boolean,:default =>false
    add_column :courses,:course_description,:string,:default =>"" #加入课程描述
  end
end
