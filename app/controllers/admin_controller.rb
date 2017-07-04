require_relative 'controller.rb'
require "sinatra/base"
require_relative "../services/session_service"



DEFAULT_ADMIN_ROUTE = "/admin/list_institutions"
DEFAULT_USER_ROUTE = "/admin/company"

class AdminController < Controller
  use Rack::Session::Cookie, :key => 'rack.session',
  :expire_after => 2592000,
  :secret => ENV['SESSION_SECRET']

  def initialize father_controller
    super father_controller
    @session_service = SessionService.new
  end
  before '/admin*' do
    @user_info = @session_service.get_user_session_info(session)
  end

  get "/admin" do
    if @user_info.is_logged_in
      if @user_info.is_admin
        redirect DEFAULT_ADMIN_ROUTE
      else
        redirect DEFAULT_USER_ROUTE
      end
    end
    erb :login, :layout => :layout
  end

  get "/admin/list_institutions" do
    if @user_info.is_admin
      @companies = Company.all(order: [:name.asc])
      @research_centers = ResearchCenter.all(order: [:name.asc])
      erb :list_institutions, :layout => :layout_admin
    else
      erb :forbidden, :layout => :layout_admin
    end
  end

  get "/admin/company" do
    if @user_info.is_logged_in
      erb :institution, :layout => :layout_admin
    else
      erb :forbidden, :layout => :layout_admin
    end
  end

  get "/admin/register" do
    if @user_info.is_logged_in and @user_info.is_admin
      @is_company = params[:type] == 'company'
      @segment = Segment.all(order: :name)
      @competence_areas = CompetenceArea.all(order: :name)
      erb :register, :layout => :layout_admin
    else
      erb :forbidden, :layout => :layout_admin
    end
  end

  post "/admin/register_submit" do
    if @user_info.is_logged_in and @user_info.is_admin
      @institution_name = params[:institution_name]
      @user_email = params[:user_email]
      @institution_cnpj = params[:institution_cnpj]
      @user_password = params[:user_password]
      @contact_name = params[:contact_name]
      @contact_email = params[:contact_email]
      @contact_name_2 = params[:contact_name_2]
      @contact_email_2 = params[:contact_email_2]
      @contact_phone = params[:contact_phone]
      @contact_site = params[:contact_site]
      @institution_description = params[:institution_description]
      @segment_list = params[:segment_list]
      @competence_list = params[:competence_list]
      @institution_type = params[:institution_type]
      return "O campo oculto do tipo de instituição deve ser preenchido" if @institution_type != "company" && @institution_type != "research_center"
      return "O nome da instituição é obrigatório." if !@institution_name || @institution_name.strip.empty?
      return "O e-mail de usuário é obrigatório." if !@user_email || @user_email.strip.empty?
      return "A senha é obrigatória" if !@user_password || @user_password.strip.empty?
      return "O e-mail do contato é obrigatório." if !@contact_email || @contact_email.strip.empty?
      return "A instituição deve possuir ao menos um segmento." if !@segment_list || @segment_list.length <= 0
      return "A instituição deve possuir ao menos uma competência" if !@competence_list || @competence_list.length <= 0
      user = User.first(email: @user_email)
      return "Email de usuário já cadastrado" if user

      user = User.new(email: @user_email, password: @user_password, role: 'user')
      contact = Contact.new(email: @contact_email, contact_name: @contact_name, site: @contact_site, phone: @contact_phone)
      if @institution_type == "company"
        institution = Company.new(name: @institution_name, description: @institution_description)
        @segment_list.each do |segment_id|
          segment = Segment.first(id: segment_id)
          if segment
            institution.segments.push(segment)
          end
        end
      else
        institution = ResearchCenter.new(name: @institution_name, description: @institution_description)
      end
      institution.contact = contact
      institution.user = user
      institution.save
      @competence_list.each do |competence_id|
        competence = Competence.first(id: competence_id)
        if competence
          competence_institution = CompetenceInstitution.create(competence_value: -1, institution: institution, competence: competence)
        end
      end
        erb :register_success, :layout => :layout_admin

    else
      erb :forbidden, :layout => :layout_admin
    end
  end

  post "/session" do
    user = @session_service.find_user_by(email: params[:email], password: params[:password])
    if(user)
      @session_service.set_user_session session, user
      return "Logado com sucesso"
    else
      return  "[erro]Usuário ou senha incorreta"
    end
  end

  get "/session/logout" do
    session.clear
    redirect "/admin"
  end
end
