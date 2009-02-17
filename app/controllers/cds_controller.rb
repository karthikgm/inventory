class CdsController < ApplicationController
  before_filter :login_required

  auto_complete_for :cd, :model
  auto_complete_for :cd, :serialnumber

  # GET /cds
  # GET /cds.xml
  def index
    @cds = Cd.paginate(
                       :page => params[:page],
                       :per_page => PER_PAGE,
                       :order => 'created_at DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cds }
    end
  end

  # GET /cds/1
  # GET /cds/1.xml
  def show
    @cd = Cd.find(params[:id])

    respond_to do |format|
      format.html { render :action => "show", :layout => "primary-content"}
      format.xml  { render :xml => @cd }
    end
  end

  # GET /cds/new
  # GET /cds/new.xml
  def new
    @cd = Cd.new

    respond_to do |format|
      format.html { render :action => "new", :layout => "primary-content"}
      format.xml  { render :xml => @cd }
    end
  end

  # GET /cds/1/edit
  def edit
    @cd = Cd.find(params[:id])
    render :action => "edit", :layout => "primary-content"
  end

  # POST /cds
  # POST /cds.xml
  def create
    @cd = Cd.new(params[:cd])

    respond_to do |format|
      if @cd.save
        flash[:notice] = 'Cd was successfully created.'
        format.html { redirect_to(@cd) }
        format.xml  { render :xml => @cd, :status => :created, :location => @cd }
      else
        format.html { render :action => "new", :layout => "primary-content" }
        format.xml  { render :xml => @cd.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cds/1
  # PUT /cds/1.xml
  def update
    @cd = Cd.find(params[:id])

    respond_to do |format|
      if @cd.update_attributes(params[:cd])
        flash[:notice] = 'Cd was successfully updated.'
        format.html { redirect_to(@cd) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit", :layout => "primary-content" }
        format.xml  { render :xml => @cd.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cds/1
  # DELETE /cds/1.xml
  def destroy
    @cd = Cd.find(params[:id])
    @cd.destroy

    respond_to do |format|
      format.html { redirect_to(cds_url) }
      format.xml  { head :ok }
    end
  end

  def search
    if not params[:cd][:model].nil?
      search_by('cds', 'Cd', params[:cd][:model], 'model', 10)
    end
    if not params[:cd][:serialnumber].nil?
      search_by('cds', 'Cd', params[:cd][:serialnumber], 'serialnumber', 10)
    end
  end
end
