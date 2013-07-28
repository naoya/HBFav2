# -*- coding: utf-8 -*-
class CategoryList
  def self.sharedCategories
    Dispatch.once { @instance ||= new }
    @instance
  end

  def initialize
    @categories = [
      { :key => nil,             :title => '総合' },
      { :key => 'social',        :title => '社会' },
      { :key => 'economics',     :title => '政治・経済' },
      { :key => 'life',          :title => '生活・人生' },
      { :key => 'entertainment', :title => 'スポーツ・芸能・音楽' },
      { :key => 'knowledge',     :title => '科学・学問' },
      { :key => 'it',            :title => 'コンピュータ・IT' },
      { :key => 'game',          :title => 'ゲーム・アニメ' } ,
      { :key => 'fun',           :title => 'おもしろ' },
    ]
  end

  def category(key)
    @categories.find { |c| c[:key] == key }
  end

  def key_to_title(key)
    category(key)[:title]
  end

  def to_datasource
    @categories
  end
end
