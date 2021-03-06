# This file is part of Hardware Inventory.
#
#     Copyright (C) 2009 Cesar Diaz
#
#     Hardware Inventory is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program. If not, see <http://www.gnu.org/licenses/>.

module ReportSystem
  protected

  #This method generate a xls file to download with a complete list of
  #workstations
  #
  #Parameters:
  # path: way where the xls file will be save in the server application
  # worksheet: name of worksheet
  # heads: the names of first row in the xls file
  # method: is the name of method to implement in the rescue of records
  # param_id: parameter to provide the place from we need get records
  #
  #Return a .xls file with the report
  def xls_report_workstations(path,method, param_id, heads)

    @worksheet = t('workstations.list_of_equipments')
    eval %"

    workbook = Excel.new('#{RAILS_ROOT}#{path}')

    get_elements('workstations', 'Workstation', method, '(' + param_id + ')')
    page = workbook.add_worksheet(@worksheet)
    get_heads(page, heads)
    workstations_report(page, @workstations)

    workbook.close
    send_file '#{RAILS_ROOT}#{path}'

    ";
  end


  #This method generate a xls file to download with a complete list of
  #hardware for a specific place
  #
  #Parameters:
  # path: way where the xls file will be save in the server application
  # worksheet: name of worksheet
  # heads: the names of first row in the xls file
  # method: is the name of method to implement in the rescue of records
  # param_id: parameter to provide the place from we need get records
  #
  #Return a .xls file with the report
  def xls_report_complete_for_a_place(path,method, param_id, heads)
    eval %"

    workbook = Excel.new('#{RAILS_ROOT}#{path}')

    get_elements('computers', 'Computer', method, param_id)
    get_elements('screens', 'Screen', method, param_id)
    get_elements('printers', 'Printer', method, param_id)
    get_elements('workstations', 'Workstation', method, '(' + param_id + ')')

    row = 1
    page = workbook.add_worksheet(t('places.computer'))
    get_heads(page, heads)
    computers_report(page, @computers, row)

    page = workbook.add_worksheet(t('places.screen'))
    generic_report(page, @screens, row, false)

    page = workbook.add_worksheet(t('places.printer'))
    generic_report(page, @printers, row, false)

    page = workbook.add_worksheet('places.workstations')
    workstations_report(page, @workstations)

    workbook.close
    send_file '#{RAILS_ROOT}#{path}'

    ";
  end


  #This method generate a xls file to download
  #
  #Parameters:
  # path: way where the xls file will be save in the server application
  # worksheet: name of worksheet
  # model: model of data to get
  # elements: name that will be provide to the array when we get records
  # heads: the names of first row in the xls file
  # method: is the name of method to implement in the rescue of records
  # param_id: parameter to provide the place from we need get records
  #
  #Return a .xls file with the report
  def xls_report(path, worksheet, model, elements, heads, method, param_id)
    eval %"

     workbook = Excel.new('#{RAILS_ROOT}#{path}')
     page = workbook.add_worksheet('#{worksheet}')

     get_heads(page, heads)
     get_elements(elements, model, method, param_id)
     make_a_report_of(elements, page, @#{elements})

     workbook.close
     send_file '#{RAILS_ROOT}#{path}'

    ";
  end


  #This method take the parameters and write in the page of a xls
  #file the heads(first line in each column)
  def get_heads(page, heads)
    eval %"

    @heads = #{heads}
     column = 0
     @heads.each do |cab|
      page.write(0,column,cab)
      column += 1
     end

    ";
  end

  #This method get an array of elements depending of the parameters
  #
  #Parameters:
  # elements: name that will be provide to the array when we get records
  # model: model of data to get
  # method: is the name of method to implement in the rescue of records
  # param_id: parameter to provide the place from we need get records
  #
  #Return an array of elements
  def get_elements(elements, model, method, param_id)
    if param_id.empty?
      eval %"
           @#{elements} = #{model}.#{method}
      ";
    else
      eval %"
           @#{elements} = #{model}.#{method}#{param_id}
      ";
    end
  end


  #This method call distinct methods of reports depending of the type
  # of report elements
  #
  #Parameters:
  # elements: name that will be provide to the array when we get records
  # page: first row of each column
  # elements: array with elements
  #
  #Return: nothing
  def make_a_report_of(this, page, elements)
    case this
    when 'computers'
      computers_report(page, elements, nil)
    when 'screens'
      generic_report(page, elements, nil, false)
    when 'printers'
      generic_report(page, elements, nil, true)
    when 'workstations'
      workstations_report(page, elements, nil, true)
    when 'places'
      places_report(page, elements)
    when 'bills'
      bills_report(page, elements)
    end
  end


  #This method fill the the computers report
  def computers_report(page, elements, row)
    row.nil? ? row = 1 : row = row
     for object in elements
       @disks = ''
       object.harddisk.empty? ? t('phrases.n') : object.harddisk.collect {|x|
       @disks = @disks + x.description_model + " - " + x.size.to_s + " " + x.unit} rescue nil
       @memories = ''
       object.memory.empty? ? t('phrases.n') : object.memory.collect {|x|
       @memories = @memories + x.description_model + " - " + x.size.to_s + " " + x.unit} rescue nil
       @cds = ''
       object.cd.empty? ? t('phrases.n') : object.cd.collect {|x|
       @cds = @cds + x.description_model + " "} rescue nil
       @dvds = ''
       object.dvd.empty? ? t('phrases.n') : object.dvd.collect {|x|
       @dvds = @dvds + x.description_model + " "} rescue nil

       page.write(row,0,object.name)
       page.write(row,1,object.mac)
       page.write(row,2,object.ip)
       page.write(row,3,object.available == true ? t('phrases.y') : t('phrases.n'))
       page.write(row,4,object.mother_board.model_id.nil? ? t('phrases.n') :
                  object.mother_board.description_model) rescue nil
       page.write(row,5,@disks)
       page.write(row,6,@memories)
       page.write(row,7,@cds)
       page.write(row,8,@dvds)
       page.write(row,9,object.inventory_register) rescue nil
       row += 1
     end
  end


  #This method fill the a generic report that
  #can be screens or printers
  def generic_report(page, elements, row, with_place)
    row.nil? ? row = 1 : row = row
     for object in elements
       if not object.model_id.nil?
         page.write(row,0,object.description_model)
       else
         page.write(row,0, '')
       end
       page.write(row,1,object.serialnumber)
       page.write(row,2,object.place.title)
       page.write(row,3,object.inventory_register) rescue nil
       row += 1
     end
  end


  #This method fill the the places report
  def places_report(page, elements)
    row = 1
     for object in elements
       page.write(row,0,object.title)
       page.write(row,1,object.description)
       page.write(row,2,object.computer.count)
       page.write(row,3,object.screen.count)
       page.write(row,4,object.printer.count)
       page.write(row,5,Workstation.list_for_place(object.id).count.to_s)
       row += 1
     end
  end

  #This method fill the the places report
  def bills_report(page, elements)
    row = 1
     for object in elements
       page.write(row,0,object.code)
       page.write(row,1,object.company.name)
       page.write(row,2,object.date.strftime("%d/%m/%Y"))
       row += 1
     end
  end

  #This method fill the the places report
  def workstations_report(page, elements)
    row = 1
     for object in elements
       @computer = Computer.find(object.computer_id)
       @screen = Screen.find(object.screen_id)
       @printer = Printer.find(object.printer_id) rescue nil
       @place = Place.find(object.place_id)

       page.write(row,0,@computer.name)
       page.write(row,1,@computer.ip)
       page.write(row,2,@computer.mac)
       page.write(row,3,@screen.description_model)
       page.write(row,4,@screen.serialnumber)
       page.write(row,5,@printer.description_model) rescue nil
       page.write(row,6,@printer.serialnumber) rescue nil
       page.write(row,7,@place.title)
       row += 1
     end
  end

end
