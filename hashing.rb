class Hashing

  # Return an integer corresponding to the given string
  def hashCode(str)
    hash = 0

    for i in (0..str.length-1)
      hash = hash*31+str[i].ord
    end
    return hash.abs
  end

end
