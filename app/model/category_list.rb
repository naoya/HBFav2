# -*- coding: utf-8 -*-
class CategoryList
  def self.sharedCategories
    Dispatch.once { @instance ||= new }
    @instance
  end

  def initialize
    @categories = [
      { :key => nil,             :title => '総合',                :label => '総合' },
      { :key => 'social',        :title => '社会',                :label => '社会' },
      { :key => 'economics',     :title => '政治・経済',          :label => '政経' },
      { :key => 'life',          :title => '生活・人生',          :label => '生活' },
      { :key => 'entertainment', :title => 'スポーツ・芸能・音楽',:label => '芸能' },
      { :key => 'knowledge',     :title => '科学・学問',          :label => '科学' },
      { :key => 'it',            :title => 'コンピュータ・IT',    :label => 'IT' },
      { :key => 'game',          :title => 'ゲーム・アニメ',      :label => 'ゲーム' } ,
      { :key => 'fun',           :title => 'おもしろ',            :label => 'おもしろ' },
    ]
  end

  def category(key)
    @categories.find { |c| c[:key] == key }
  end

  def key_to_title(key)
    category(key)[:title]
  end

  def key_to_label(key)
    category(key)[:label]
  end

  def to_datasource
    @categories
  end
end
