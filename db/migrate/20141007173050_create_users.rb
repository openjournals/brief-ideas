class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :provider
      t.string  :uid
      t.string  :name
      t.string  :oauth_token
      t.string  :oauth_expires_at
      t.string  :avatar_url
      t.text    :extra
      t.string  :email
      t.string  :sha
      t.boolean :admin, :default => false
      t.timestamps
    end
  end
end
