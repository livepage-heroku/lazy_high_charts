# coding: utf-8
module LazyHighCharts
  module LayoutHelper

    def high_chart(placeholder, object, use_wrapper=true, &block)
      object.html_options.merge!({:id=>placeholder})
      object.options[:chart][:renderTo] = placeholder
      graph = high_graph(placeholder,object, use_wrapper, &block)
      graph.concat(content_tag("div","", object.html_options)) if use_wrapper
    end

    def high_stock(placeholder, object, &block)
      object.html_options.merge!({:id=>placeholder})
      object.options[:chart][:renderTo] = placeholder
      high_graph_stock(placeholder,object , &block).concat(content_tag("div","", object.html_options))
    end

    def high_graph(placeholder, object, use_wrapper=true, &block)
      build_html_output("Chart", placeholder, object, use_wrapper, &block)
    end

    def high_graph_stock(placeholder, object, &block)
      build_html_output("StockChart", placeholder, object, &block)
    end

    def build_html_output(type, placeholder, object, use_wrapper=true, &block)
      options_collection = []
      object.options.keys.each do |key|
        k = key.to_s.camelize.gsub!(/\b\w/) { $&.downcase }
        options_collection << "#{k}: #{object.options[key].to_json}"
      end
      options_collection << "series: #{object.data.to_json}"

      graph =<<-EOJS
          var options, chart;
          options = { #{options_collection.join(",")} };
          #{capture(&block) if block_given?}
          chart = new Highcharts.#{type}(options);
      EOJS

      if use_wrapper
        graph =<<-EOJS
        <script type="text/javascript">
        (function() {
          var onload = window.onload;
          window.onload = function(){
            if (typeof onload == "function") onload();
            #{graph}
          };
        })()
        </script>
        EOJS
      end

      if defined?(raw)
        return raw(graph) 
      else
        return graph
      end

    end
  end
end
