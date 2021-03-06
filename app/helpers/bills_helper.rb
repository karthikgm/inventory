module BillsHelper

  def show_data(data, object, label)
    html = ''
    if object > 0
      html = html + content_tag('label', label,  :id => "bill-content" )
      html = html + content_tag('ul', data.collect {|x| x.description_model + \
                                  ' ' + x.serialnumber \
                                  + '<br>' },  :id => "bill-content-decription" )
    end
    return html
  end

end
