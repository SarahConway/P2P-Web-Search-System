class Hashing

  def hashCode(str)
    hash = 0

    for i in (0..str.length-1)
      hash = hash*31+str[i].ord
      #puts(i.to_s + " Hash: " + hash.to_s)
    end
    return hash.abs
  end

end
