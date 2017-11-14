class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweet do |t|
      t.string :content
    end
  end
end
