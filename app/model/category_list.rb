# -*- coding: utf-8 -*-
class CategoryList
  def self.sharedCategories
    Dispatch.once { @instance ||= new }
    @instance
  end

  def initialize
    @categories = [
      { :key => nil,             :title => '総合',                :label => '総合' },
      { :key => 'social',        :title => '世の中',              :label => '世の中' },
      { :key => 'economics',     :title => '政治と経済',          :label => '政経' },
      { :key => 'life',          :title => '暮らし',              :label => '暮らし' },
      { :key => 'entertainment', :title => 'エンタメ',            :label => 'エンタメ' },
      { :key => 'knowledge',     :title => '学び',                :label => '学び' },
      { :key => 'it',            :title => 'テクノロジー',        :label => 'IT' },
      { :key => 'game',          :title => 'アニメとゲーム',      :label => 'アニメ' } ,
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
    @categories.select {|item| item[:key].present? }
  end
end
