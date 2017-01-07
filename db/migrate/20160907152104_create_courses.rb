class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|

      t.string :name
      t.string :course_code
      t.string :teaching_type
      t.string :exam_type
      t.string :course_type
      t.integer :period,   default: 0        #学时
      t.float :credit              #学分
      t.integer :limit_num ,default:0
      t.integer :student_num, default: 0
      t.string :class_room
      t.string :course_time       #字段不变，但内容改变
      t.string :course_week
      #t.integer :start_week       #开始周
      #t.integer :end_week         #结束周
      t.text    :description, default: ""      #课程简介
      t.belongs_to :teacher
      t.timestamps null: false
    end
  end
end
