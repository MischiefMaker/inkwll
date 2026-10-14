# Forum boards: places for things that suit a forum better than a Chapter,
# such as news, advertising and wanted ads. Staff set up the boards and who
# may start threads and reply on each one.
class CreateForums < ActiveRecord::Migration[8.1]
  def change
    create_table :forum_boards do |t|
      t.string :name, null: false
      t.text :description
      t.integer :position, null: false, default: 0
      # Who may start a thread, and who may reply: see ForumBoard::POSTERS.
      t.string :who_can_start, null: false, default: "everyone"
      t.string :who_can_reply, null: false, default: "everyone"
      t.timestamps
    end

    create_table :forum_topics do |t|
      t.references :board, null: false, foreign_key: { to_table: :forum_boards, on_delete: :cascade }
      t.references :account, foreign_key: { on_delete: :nullify }
      t.string :title, null: false
      t.datetime :pinned_at
      t.datetime :locked_at
      t.datetime :last_posted_at, null: false
      t.integer :posts_count, null: false, default: 0
      t.timestamps
    end
    add_index :forum_topics, [ :board_id, :last_posted_at ]

    create_table :forum_posts do |t|
      t.references :topic, null: false, foreign_key: { to_table: :forum_topics, on_delete: :cascade }
      t.references :account, foreign_key: { on_delete: :nullify }
      t.text :body, null: false
      t.datetime :edited_at
      t.timestamps
    end
    add_index :forum_posts, [ :topic_id, :created_at ]
  end
end
