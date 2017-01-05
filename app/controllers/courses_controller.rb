class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update, :student_list]
  before_action :logged_in, only: :index
#/-------------------------------------------------liwenqi add these comments-
  def show_owned
     @grades=current_user.grades
     @course_f=Array.new
     @grades.each do |grade|
      if grade.favorite==false then
         @course_f.push grade.course
      end
    end
    @course=@course_f
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
  def list_all
    @course=Course.all
    @course=@course-current_user.courses
end

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

def select
    @course=Course.find_by_id(params[:id])
    @course.student_num=@course.grades.where(favorite: false).length
    @grades=current_user.grades.where(favorite: false)
    flag=false
    flag1=false
    flag2=false
    @grades.each do|nowcourse|
        if nowcourse.course.name==@course.name
          flag=true
          break
        end

        if nowcourse.course.course_time[1]==@course.course_time[1]
            time1 = (nowcourse.course.course_time[3].to_i..nowcourse.course.course_time[4..5].to_i).to_a
            time2 = (@course.course_time[3].to_i..@course.course_time[4..5].to_i).to_a
          if (time1 & time2)!=[]
            flag1=true
            break
          end
        end
    end
    if (@course.limit_num > @course.student_num) ||  (@course.limit_num == 0)
      flag2=true
    end

    if flag==false
        if flag1==false and flag2==true
  
            @course.student_num += 1
            @course.save
            current_user.courses<< @course  ##把该用户的课程信息添加到表示当前用户变量的
                                       ##current_user中 方便之后使用。
            flash={:success => "成功选择课程: #{@course.name}"}
            redirect_to courses_path, flash: flash
        else
            flash={:danger =>"#{@course.name} 选课失败，课程选课时间冲突，请选择其他课程! "}
            redirect_to courses_path, flash: flash
        end

    else
        if flag==true
          flash={:danger =>"#{@course.name} 选课失败，同课程名冲突，请选择其他课程! "}
          redirect_to courses_path, flash: flash
        elsif flag2==false
                  flash={:warning => "选课人数已满: #{@course.name} 无法选课" }
                  redirect_to courses_path, flash: flash
        end
    end
end

def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    @course.student_num -=1
    @course.save
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
end
  #-------------------------收藏夹相关----------------------
  
def add_favorite
  @course=Course.find_by_id(params[:id])
  #current_user.courses<<@course
  #l=current_user.grades.length
  current_user.courses.push @course
  @grade=current_user.grades.last
  @grade.update_attributes(favorite:true)
  flash={:success => "成功收藏课程: #{@course.name}"}
  redirect_to list_favorite_courses_path, flash: flash
end

def list_favorite
   @grades=current_user.grades
    @course_f=Array.new
     @grades.each do |grade|
      if grade.favorite==true then
         @course_f.push grade.course
      end
    end
    @course=@course_f
end

def quit_f
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    @course.save
    flash={:success => "成功从收藏夹去掉课程: #{@course.name}"}
    redirect_to list_favorite_courses_path, flash: flash
end

def from_f
  @grades=current_user.grades
  @grades.each do |grade|
       grade.update_attributes(favorite:false)
  end 
  flash={:success => "成功导入"}
  redirect_to courses_path, flash: flash
end

def conflict_f
  @grades=current_user.grades.where(:favorite=>"true")
    if @grades.length==0
    flash={:danger => "未收藏任何课程"}
   elsif @grades.length==1
    flash={:success => "没有时间冲突的课程"}
   else
          @grades.each do |grade|
                     time1 = (grade.course.course_time[3].to_i..grade.course.course_time[4..5].to_i).to_a
                     week1=grade.course.course_time[1]
                     name1=grade.course.name
                     @grades.each do|grade1|
                          time2 = (grade1.course.course_time[3].to_i..grade1.course.course_time[4..5].to_i).to_a
                          week2=grade1.course.course_time[1]
                          name2=grade1.course.name
                          if name1==name2
                            next
                          elsif (time1 & time2)!=[] && week1==week2
                            flash={:danger => "课程：#{name1}—与—课程：#{name2}——时间有冲突"}
                            break
                          end
                      end
           end
    end 
redirect_to list_favorite_courses_path,flash: flash
end


  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses if teacher_logged_in?
   if student_logged_in?
    @grades=current_user.grades
    @course_f=Array.new
    @grades.each do |grade|
      if grade.favorite==false then
         @course_f.push grade.course
      end
    end
    @course=@course_f
  end
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

#定义一些函数

end