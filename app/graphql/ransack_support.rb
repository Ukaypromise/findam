# frozen_string_literal: true

module RansackSupport
  def ransack(base, **args)
    base.ransack(build_ransack_query(base, **args)).result
  end

  def build_ransack_query(base, **args)
    atts = base.ransackable_attributes
    sort = args.delete(:sort)
    ransack_params = args.reduce({}) do |memo, (k,v)|
      memo[atts.include?(k.to_s) ? :"#{k}_eq" : k] = v
      memo
    end
    if sort
      ransack_params[:s] = "#{sort[:column]} #{sort[:direction]}"
    end
    ransack_params
  end
end
