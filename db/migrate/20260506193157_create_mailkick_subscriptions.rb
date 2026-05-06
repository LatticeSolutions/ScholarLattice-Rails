class CreateMailkickSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :mailkick_subscriptions, id: :uuid do |t|
      t.references :subscriber, type: :uuid, polymorphic: true, index: false
      t.string :list
      t.timestamps
    end

    add_index :mailkick_subscriptions, [ :subscriber_type, :subscriber_id, :list ], unique: true, name: "index_mailkick_subscriptions_on_subscriber_and_list"
  end
end
