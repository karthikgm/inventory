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

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Take and object and depending if it is true make a help advice
  #
  # Return: html
  def advice(object, head, message, width, id)
    html = ''
    if  object
      html = html + '<div class="' + width + '" id="' + id + '" >'
      html = html + "<a href=\"#\" onclick=\"Effect.toggle('" + id + "', 'appear'); return false;\">"
      html = html +  head + '</a>'
      html = html +  '<br>'
      html = html +  message
      html = html +  '</div>'
    end
    return html

  end

  # Take and object and depending if it is true make a help advice
  #
  # Return: html
  def front_end_pages()
    html = ''

    Page.find(:all).collect { |page|
      html = html + '<div id="options" >'
      html = html + link_to(page.permalink, '/' + page.permalink )
      html = html +  '</div>'
    }
    return html
  end

  #Get a value and depending of the value return a phrase
  #
  #Return: - yes if value is true
  #        - no if value is false
  def check(value)
    html = ''
    if value
      html = html +  t('phrases.y')
    else
      html = html +  t('phrases.n')
    end
    return html
  end

  #Get a value and depending of the value return a link or a phrase
  #
  #Return: - link if value is true
  #        - no if value is false
  def in_workstation?(value, device)
    html = ''
    if value.is_part_of_a_workstation
      html = html +  link_to(t('phrases.y'), :controller => 'workstations',
                             :action => 'show',
                             :id => Workstation.find(:first,
                                                     :conditions => [ "#{device} = ?", value.id]).id)
    else
      html = html +  t('phrases.n')
    end
    return html
  end

  # Take and object and depending if it is true make a help advice
  #
  # Return: html
  def show_info(label, css, object, value, field)
    html = "<div id='#{css}'>"
    html = html + label + ' : '
    eval %"
        @value = #{object}.find(:first, :conditions => [ 'id = ?', #{value}]).#{field}
    ";
    html = html +  @value
    html = html + '</div>'
    return html
  end

  # Take and object and depending of the attribute 'description'
  # it will return a translate value
  #
  # Return: html
  def which_type_of_place_is?(place)
    html = ''
    case place
    when 'store'
      html = html + t('places.stores')
    when 'office'
      html = html + t('places.offices')
    when 'room'
      html = html + t('places.rooms')
    when 'department'
      html = html + t('places.departments')
    end

    return html.to_s
  end

  def set_charset
    if logged_in? and  I18n.locale === 'fr'
      @content = '<meta http-equiv="content-type" content= "text/html; charset=iso-8859-1" />'
    else
      @content = '<meta http-equiv="content-type" content= "text/html; charset=utf-8" />'
    end
    return @content
  end

end
