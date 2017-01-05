class GradesController < ApplicationController

  before_action :teacher_logged_in, only: [:update]

  def update
    @grade=Grade.find_by_id(params[:id])
    if @grade.update_attributes!(:grade => params[:grade][:grade])
      flash={:success => "#{@grade.user.name} #{@grade.course.name}的成绩已成功修改为 #{@grade.grade}"}
    else
      flash={:danger => "上传失败.请重试"}
    end
    redirect_to grades_path(course_id: params[:course_id]), flash: flash
  end

  def index
    if teacher_logged_in?
      @course=Course.find_by_id(params[:course_id])
      @grades=@course.grades.where(favorite: false)
      
       #gaolu16增加统计成绩
      count_student_grade(@grades)
      
    elsif student_logged_in?
      @grades=current_user.grades
        #gaolu16增加统计成绩
      @grade_true=Array.new
      @grades.each do |every_grades|
      if every_grades.grade then
         @grade_true.push every_grades
      end
    end 
    @grades=@grade_true
    else
      redirect_to root_path, flash: {:warning=>"请先登陆"}
    end
  end


  private

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end
  
#统计学生成绩情况，用数组存储学生不同的成绩
def count_student_grade(grades)
    @grades=grades
    @our_grade=[0,0,0,0,0]
    @grades.each do |grade|
      unless grade.grade.nil?
      case grade.grade
      when 90..100
        @our_grade[0]+=1
      when 80 .. 90
        @our_grade[1]+=1 
      when 70 .. 80
        @our_grade[2]+=1
      when 60 .. 70
        @our_grade[3]+=1
      else 
        @our_grade[4]+=1 
      end
      end
    end
    return @our_grade
end

end
