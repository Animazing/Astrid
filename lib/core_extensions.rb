class String
  def start_with?(prefix)
   prefix = prefix.to_s
   self[0, prefix.length] == prefix
  end
end