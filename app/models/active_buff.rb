#=======================================|ACTIVEBUFF TABLE SCHEMA|=======================================
#
# table name: active_buffs
#
# buffs_id                :bigint       null: false, foreign key of buff
# buffable_type           :string       polymorphic class
# buffable_id             :bigint       polymorphic ID
#
class ActiveBuff < ApplicationRecord
  belongs_to :buff
  belongs_to :buffable, polymorphic: true
end
