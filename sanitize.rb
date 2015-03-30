class String
  def sanitize
    hash = {
      '/' => '／',
      '\\' => '＼',
      '¥' => '￥',
      '?' => '？',
      '%' => '％',
      '*' => '＊',
      ':' => '：',
      '|' => '｜',
      '"' => '”',
      '<' => '＜',
      '>' => '＞'
    }
    self.gsub(/[\/\\\?%\*:|"<>]/, hash)
  end
end
