class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update, :student_list]
  before_action :logged_in, only: :index
#/-------------------------------------------------liwenqi add these comments-
  def show_owned
    @course=current_user.courses
    #对课程进行排序
    @course=@course.sort_by{|e| e[:course_time]}
  end
  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end
  
def open
  @course=Course.find_by_id(params[:id])
  @course.update_attributes(open:true)
  redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
end

def close
  @course=Course.find_by_id(params[:id])
  @course.update_attributes(open:false)
  redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
end

#------12.31日更新
  def student_list
    @course = Course.find_by_id(params[:id])
    @user = @course.users
  end
  
  #-------------------------for students----------------------

  def list
    @q1=params[:name]
  # @q2=params[:course_type]
    if @q1.nil? == false 
      @course = Course.where("name like '#{@q1}' ")
     else
      @course=Course.all
    end
    #if @q2.nil? == false  
     # @course = Course.where("course_type like '#{@q2}' ")
    # else
    #  @course=Course.all
    #end
    @course=@course - current_user.courses
    @course_true=Array.new
    @course.each do |every_course|
      if every_course.open_was then
         @course_true.push every_course
      end
    end 
    @course=@course_true
  end
  
  #定义全部课程显示
  def list_all
    @course=Course.all
  end
    
  def select
    @course=Course.find_by_id(params[:id])
    current_user.courses<<@course
    flash={:success => "成功选择课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end


  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses if teacher_logged_in?
    @course=current_user.courses if student_logged_in?
  end


  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week)
  end


end
