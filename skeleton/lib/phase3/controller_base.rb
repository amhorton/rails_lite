require_relative '../phase2/controller_base'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'

module Phase3
  class ControllerBase < Phase2::ControllerBase
    # use ERB and binding to evaluate templates
    # pass the rendered html to render_content
    def render(template_name)
      raise if already_built_response?

      controller_name = self.class.to_s.underscore

      template = File.read("views/#{controller_name}/#{template_name}.html.erb")

      erb_template = ERB.new(template)
      
      render_content(erb_template.result(binding), "text/html")
      @already_built_response = true
    end
  end
end
