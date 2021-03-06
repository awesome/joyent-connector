# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 177) do

  create_table "addresses", :force => true do |t|
    t.column "person_id",    :integer
    t.column "preferred",    :boolean
    t.column "address_type", :string,  :default => ""
    t.column "street",       :string,  :default => ""
    t.column "city",         :string,  :default => ""
    t.column "state",        :string,  :default => ""
    t.column "postal_code",  :string,  :default => ""
    t.column "geocode",      :string,  :default => ""
    t.column "country_name", :string,  :default => ""
  end

  add_index "addresses", ["person_id"], :name => "addresses_person_id_index"

  create_table "affiliates", :force => true do |t|
    t.column "name", :string
  end

  add_index "affiliates", ["name"], :name => "index_affiliates_on_name"

  create_table "auth_keys", :force => true do |t|
    t.column "key",             :string
    t.column "organization_id", :integer
    t.column "user_id",         :integer
    t.column "created_at",      :datetime
  end

  create_table "bookmark_folders", :force => true do |t|
    t.column "user_id",         :integer
    t.column "organization_id", :integer
  end

  add_index "bookmark_folders", ["user_id"], :name => "bookmark_folders_user_id_index"
  add_index "bookmark_folders", ["organization_id"], :name => "index_bookmark_folders_on_organization_id"

  create_table "bookmarks", :force => true do |t|
    t.column "organization_id",    :integer
    t.column "user_id",            :integer
    t.column "bookmark_folder_id", :integer
    t.column "uri",                :text
    t.column "uri_sha1",           :text
    t.column "title",              :text
    t.column "notes",              :text
    t.column "created_at",         :datetime
    t.column "updated_at",         :datetime
  end

  add_index "bookmarks", ["bookmark_folder_id"], :name => "bookmarks_bookmark_folder_id_index"
  add_index "bookmarks", ["organization_id"], :name => "bookmarks_organization_id_index"
  add_index "bookmarks", ["user_id"], :name => "bookmarks_user_id_index"

  create_table "calendar_subscriptions", :force => true do |t|
    t.column "name",             :string
    t.column "user_id",          :integer
    t.column "organization_id",  :integer
    t.column "url",              :string
    t.column "username",         :string
    t.column "password",         :string
    t.column "update_frequency", :string
    t.column "created_at",       :datetime
    t.column "updated_at",       :datetime
  end

  create_table "calendars", :force => true do |t|
    t.column "user_id",         :integer
    t.column "name",            :string,   :default => ""
    t.column "created_at",      :datetime
    t.column "updated_at",      :datetime
    t.column "parent_id",       :integer
    t.column "organization_id", :integer
  end

  add_index "calendars", ["parent_id"], :name => "calendars_parent_id_index"
  add_index "calendars", ["user_id"], :name => "calendars_user_id_index"
  add_index "calendars", ["organization_id"], :name => "index_calendars_on_organization_id"

  create_table "callings", :force => true do |t|
    t.column "call_id",      :integer
    t.column "callee_id",    :integer
    t.column "phone_number", :string
  end

  create_table "calls", :force => true do |t|
    t.column "caller_id",   :integer
    t.column "status_code", :integer
    t.column "created_at",  :datetime
  end

  create_table "comments", :force => true do |t|
    t.column "user_id",          :integer
    t.column "body",             :text
    t.column "created_at",       :datetime
    t.column "updated_at",       :datetime
    t.column "commentable_id",   :integer
    t.column "commentable_type", :string
  end

  add_index "comments", ["commentable_id"], :name => "comments_commentable_id_index"
  add_index "comments", ["commentable_type"], :name => "comments_commentable_type_index"
  add_index "comments", ["user_id"], :name => "comments_user_id_index"

  create_table "contact_lists", :force => true do |t|
    t.column "user_id",         :integer
    t.column "organization_id", :integer
  end

  add_index "contact_lists", ["user_id"], :name => "contact_lists_user_id_index"
  add_index "contact_lists", ["organization_id"], :name => "index_contact_lists_on_organization_id"

  create_table "domains", :force => true do |t|
    t.column "organization_id", :integer
    t.column "web_domain",      :string
    t.column "email_domain",    :string
    t.column "primary",         :boolean
    t.column "system_domain",   :boolean
  end

  add_index "domains", ["organization_id"], :name => "domains_organization_id_index"
  add_index "domains", ["web_domain"], :name => "domains_web_domain_index"

  create_table "email_addresses", :force => true do |t|
    t.column "person_id",     :integer
    t.column "preferred",     :boolean, :default => false
    t.column "email_type",    :string,  :default => ""
    t.column "email_address", :string,  :default => ""
    t.column "use_notifier",  :boolean
  end

  add_index "email_addresses", ["person_id"], :name => "email_addresses_person_id_index"

  create_table "events", :force => true do |t|
    t.column "organization_id",           :integer
    t.column "user_id",                   :integer
    t.column "name",                      :string
    t.column "location",                  :text
    t.column "start_time",                :datetime
    t.column "recur_end_time",            :datetime
    t.column "notes",                     :text
    t.column "created_at",                :datetime
    t.column "updated_at",                :datetime
    t.column "all_day",                   :boolean
    t.column "recurrence_description_id", :integer
    t.column "end_time",                  :datetime
    t.column "recurrence_name",           :string
    t.column "alarm_trigger_in_minutes",  :integer
    t.column "by_day",                    :string
    t.column "next_fire",                 :datetime
    t.column "fired",                     :boolean
    t.column "calendar_subscription_id",  :integer
  end

  add_index "events", ["organization_id"], :name => "events_organization_id_index"
  add_index "events", ["user_id"], :name => "events_user_id_index"

  create_table "folders", :force => true do |t|
    t.column "user_id",         :integer
    t.column "parent_id",       :integer
    t.column "name",            :string
    t.column "created_at",      :datetime
    t.column "updated_at",      :datetime
    t.column "organization_id", :integer
  end

  add_index "folders", ["parent_id"], :name => "folders_parent_id_index"
  add_index "folders", ["user_id"], :name => "folders_user_id_index"
  add_index "folders", ["organization_id"], :name => "index_folders_on_organization_id"

  create_table "guest_paths", :force => true do |t|
    t.column "user_id",       :integer
    t.column "guest_id",      :integer
    t.column "relative_path", :string
  end

  add_index "guest_paths", ["guest_id"], :name => "index_guest_paths_on_guest_id"
  add_index "guest_paths", ["user_id"], :name => "index_guest_paths_on_user_id"

  create_table "identities", :force => true do |t|
    t.column "name", :string, :default => ""
  end

  create_table "im_addresses", :force => true do |t|
    t.column "person_id",    :integer
    t.column "preferred",    :boolean, :default => false
    t.column "im_type",      :string,  :default => ""
    t.column "im_address",   :string,  :default => ""
    t.column "use_notifier", :boolean
  end

  add_index "im_addresses", ["person_id"], :name => "im_addresses_person_id_index"

  create_table "invitations", :force => true do |t|
    t.column "event_id",    :integer
    t.column "user_id",     :integer
    t.column "calendar_id", :integer
    t.column "accepted",    :boolean
    t.column "pending",     :boolean, :default => true
  end

  add_index "invitations", ["calendar_id"], :name => "invitations_calendar_id_index"
  add_index "invitations", ["event_id"], :name => "invitations_event_id_index"
  add_index "invitations", ["user_id"], :name => "invitations_user_id_index"

  create_table "joyent_files", :force => true do |t|
    t.column "organization_id",              :integer
    t.column "user_id",                      :integer
    t.column "size_in_bytes",                :integer,  :null => false
    t.column "notes",                        :text
    t.column "created_at",                   :datetime
    t.column "updated_at",                   :datetime
    t.column "folder_id",                    :integer
    t.column "filename",                     :string
    t.column "joyent_file_type_description", :string
  end

  add_index "joyent_files", ["folder_id"], :name => "joyent_files_folder_id_index"
  add_index "joyent_files", ["organization_id"], :name => "joyent_files_organization_id_index"
  add_index "joyent_files", ["user_id"], :name => "joyent_files_user_id_index"

  create_table "list_cells", :force => true do |t|
    t.column "list_column_id", :integer
    t.column "list_row_id",    :integer
    t.column "value",          :text
  end

  create_table "list_columns", :force => true do |t|
    t.column "list_id",  :integer
    t.column "position", :integer
    t.column "name",     :string
    t.column "kind",     :string
  end

  create_table "list_folders", :force => true do |t|
    t.column "user_id",         :integer
    t.column "parent_id",       :integer
    t.column "name",            :string
    t.column "created_at",      :datetime
    t.column "updated_at",      :datetime
    t.column "organization_id", :integer
  end

  create_table "list_rows", :force => true do |t|
    t.column "list_id",          :integer
    t.column "parent_id",        :integer
    t.column "position",         :integer
    t.column "children_count",   :integer,  :default => 0,    :null => false
    t.column "created_at",       :datetime
    t.column "updated_at",       :datetime
    t.column "visible_children", :boolean,  :default => true
    t.column "depth_cache",      :integer
  end

  create_table "lists", :force => true do |t|
    t.column "organization_id", :integer
    t.column "user_id",         :integer
    t.column "name",            :string
    t.column "created_at",      :datetime
    t.column "updated_at",      :datetime
    t.column "list_folder_id",  :integer
  end

  create_table "login_tokens", :force => true do |t|
    t.column "value",      :string
    t.column "user_id",    :integer
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "login_tokens", ["user_id"], :name => "index_login_tokens_on_user_id"
  add_index "login_tokens", ["value"], :name => "login_tokens_value_index"

  create_table "mail_alias_memberships", :force => true do |t|
    t.column "user_id",       :integer
    t.column "mail_alias_id", :integer
    t.column "created_at",    :datetime
    t.column "updated_at",    :datetime
  end

  create_table "mail_aliases", :force => true do |t|
    t.column "name",            :string
    t.column "organization_id", :integer
    t.column "created_at",      :datetime
    t.column "updated_at",      :datetime
  end

  create_table "mailboxes", :force => true do |t|
    t.column "uid_validity",    :integer
    t.column "uid_next",        :integer
    t.column "user_id",         :integer
    t.column "created_at",      :datetime
    t.column "updated_at",      :datetime
    t.column "parent_id",       :integer
    t.column "full_name",       :string
    t.column "organization_id", :integer
  end

  add_index "mailboxes", ["organization_id"], :name => "index_mailboxes_on_organization_id"
  add_index "mailboxes", ["parent_id"], :name => "mailboxes_parent_id_index"
  add_index "mailboxes", ["uid_next"], :name => "mailboxes_uid_next_index"
  add_index "mailboxes", ["uid_validity"], :name => "mailboxes_uid_validity_index"
  add_index "mailboxes", ["user_id"], :name => "mailboxes_user_id_index"

  create_table "messages", :force => true do |t|
    t.column "organization_id", :integer
    t.column "user_id",         :integer
    t.column "mailbox_id",      :integer
    t.column "size_in_bytes",   :integer
    t.column "created_at",      :datetime
    t.column "updated_at",      :datetime
    t.column "internaldate",    :datetime
    t.column "has_attachments", :boolean
    t.column "sender",          :text
    t.column "subject",         :text
    t.column "date",            :datetime
    t.column "seen",            :boolean
    t.column "recipients",      :text
    t.column "joyent_id",       :string
    t.column "active",          :boolean,  :default => true
    t.column "flagged",         :boolean,  :default => false
    t.column "draft",           :boolean,  :default => false
    t.column "answered",        :boolean,  :default => false
    t.column "forwarded",       :boolean,  :default => false
    t.column "status",          :text
    t.column "filename",        :string
  end

  add_index "messages", ["mailbox_id"], :name => "messages_mailbox_id_index"
  add_index "messages", ["organization_id"], :name => "messages_organization_id_index"
  add_index "messages", ["user_id"], :name => "messages_user_id_index"
  add_index "messages", ["filename"], :name => "index_messages_on_filename"

  create_table "notifications", :force => true do |t|
    t.column "organization_id", :integer
    t.column "notifiee_id",     :integer
    t.column "notifier_id",     :integer
    t.column "item_id",         :integer
    t.column "item_type",       :string
    t.column "acknowledged",    :boolean,  :default => false
    t.column "created_at",      :datetime
    t.column "updated_at",      :datetime
    t.column "message",         :text
  end

  add_index "notifications", ["item_id"], :name => "notifications_item_id_index"
  add_index "notifications", ["item_type"], :name => "notifications_item_type_index"
  add_index "notifications", ["notifiee_id"], :name => "notifications_notifiee_id_index"
  add_index "notifications", ["notifier_id"], :name => "notifications_notifier_id_index"
  add_index "notifications", ["organization_id"], :name => "notifications_organization_id_index"

  create_table "organizations", :force => true do |t|
    t.column "name",         :string
    t.column "active",       :boolean, :default => true
    t.column "affiliate_id", :integer, :default => 1
    t.column "disk_usage",   :integer, :default => 0,    :null => false
  end

  add_index "organizations", ["affiliate_id"], :name => "index_organizations_on_affiliate_id"

  create_table "people", :force => true do |t|
    t.column "name_prefix",         :string,   :default => ""
    t.column "first_name",          :string,   :default => ""
    t.column "middle_name",         :string,   :default => ""
    t.column "last_name",           :string,   :default => ""
    t.column "name_suffix",         :string,   :default => ""
    t.column "nickname",            :string,   :default => ""
    t.column "company_name",        :string,   :default => ""
    t.column "title",               :string,   :default => ""
    t.column "time_zone",           :string,   :default => ""
    t.column "notes",               :text
    t.column "created_at",          :datetime
    t.column "updated_at",          :datetime
    t.column "organization_id",     :integer
    t.column "user_id",             :integer
    t.column "contact_list_id",     :integer
    t.column "person_type",         :string
    t.column "primary_email_cache", :string
    t.column "primary_phone_cache", :string
  end

  add_index "people", ["contact_list_id"], :name => "people_contact_list_id_index"
  add_index "people", ["organization_id"], :name => "people_organization_id_index"
  add_index "people", ["user_id"], :name => "people_user_id_index"

  create_table "permissions", :force => true do |t|
    t.column "user_id",   :integer
    t.column "item_id",   :integer
    t.column "item_type", :string
  end

  add_index "permissions", ["item_id"], :name => "permissions_item_id_index"
  add_index "permissions", ["item_type"], :name => "permissions_item_type_index"
  add_index "permissions", ["user_id"], :name => "permissions_user_id_index"

  create_table "person_group_memberships", :force => true do |t|
    t.column "person_id",       :integer
    t.column "person_group_id", :integer
    t.column "created_at",      :datetime
    t.column "updated_at",      :datetime
  end

  create_table "person_groups", :force => true do |t|
    t.column "user_id",         :integer
    t.column "organization_id", :integer
    t.column "name",            :string
    t.column "created_at",      :datetime
    t.column "updated_at",      :datetime
  end

  create_table "phone_numbers", :force => true do |t|
    t.column "person_id",           :integer
    t.column "preferred",           :boolean, :default => false
    t.column "phone_number_type",   :string,  :default => ""
    t.column "phone_number",        :string,  :default => ""
    t.column "confirmation_number", :string
    t.column "confirmed",           :boolean, :default => false
    t.column "provider",            :string
    t.column "use_notifier",        :boolean
  end

  add_index "phone_numbers", ["person_id"], :name => "phone_numbers_person_id_index"

  create_table "quotas", :force => true do |t|
    t.column "organization_id", :integer
    t.column "users",           :integer
    t.column "custom_domains",  :boolean
    t.column "megabytes",       :integer
  end

  add_index "quotas", ["organization_id"], :name => "quotas_organization_id_index"

  create_table "report_descriptions", :force => true do |t|
    t.column "name", :string
  end

  add_index "report_descriptions", ["name"], :name => "report_descriptions_name_index"

  create_table "reports", :force => true do |t|
    t.column "report_description_id", :integer
    t.column "reportable_id",         :integer
    t.column "reportable_type",       :string
    t.column "position",              :integer
    t.column "organization_id",       :integer
    t.column "user_id",               :integer
    t.column "created_at",            :datetime
    t.column "updated_at",            :datetime
  end

  add_index "reports", ["organization_id"], :name => "reports_organization_id_index"
  add_index "reports", ["report_description_id"], :name => "reports_report_description_id_index"
  add_index "reports", ["reportable_id"], :name => "reports_reportable_id_index"
  add_index "reports", ["reportable_type"], :name => "reports_reportable_type_index"
  add_index "reports", ["user_id"], :name => "reports_user_id_index"

  create_table "sessions", :force => true do |t|
    t.column "session_id", :string
    t.column "data",       :text
    t.column "updated_at", :datetime
    t.column "created_at", :datetime
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "smart_group_attribute_descriptions", :force => true do |t|
    t.column "name",                       :string
    t.column "attribute_name",             :string
    t.column "smart_group_description_id", :integer
    t.column "body",                       :boolean
  end

  add_index "smart_group_attribute_descriptions", ["smart_group_description_id"], :name => "smart_group_attribute_descriptions_smart_group_description_id_i"

  create_table "smart_group_attributes", :force => true do |t|
    t.column "value",                                :string
    t.column "smart_group_id",                       :integer
    t.column "smart_group_attribute_description_id", :integer
  end

  add_index "smart_group_attributes", ["smart_group_attribute_description_id"], :name => "smart_group_attributes_smart_group_attribute_description_id_ind"
  add_index "smart_group_attributes", ["smart_group_id"], :name => "smart_group_attributes_smart_group_id_index"

  create_table "smart_group_descriptions", :force => true do |t|
    t.column "name",      :string
    t.column "item_type", :string
  end

  add_index "smart_group_descriptions", ["item_type"], :name => "smart_group_descriptions_item_type_index"
  add_index "smart_group_descriptions", ["name"], :name => "smart_group_descriptions_name_index"

  create_table "smart_groups", :force => true do |t|
    t.column "name",                       :string
    t.column "smart_group_description_id", :integer
    t.column "user_id",                    :integer
    t.column "accept_any",                 :boolean
    t.column "tags",                       :text
    t.column "organization_id",            :integer
    t.column "special",                    :boolean, :default => false
  end

  add_index "smart_groups", ["organization_id"], :name => "index_smart_groups_on_organization_id"
  add_index "smart_groups", ["smart_group_description_id"], :name => "smart_groups_smart_group_description_id_index"
  add_index "smart_groups", ["user_id"], :name => "smart_groups_user_id_index"

  create_table "special_dates", :force => true do |t|
    t.column "person_id",    :integer
    t.column "preferred",    :boolean, :default => false
    t.column "description",  :text
    t.column "special_date", :date
  end

  add_index "special_dates", ["person_id"], :name => "special_dates_person_id_index"

  create_table "subscriptions", :force => true do |t|
    t.column "subscribable_id",   :integer
    t.column "subscribable_type", :string
    t.column "organization_id",   :integer
    t.column "user_id",           :integer
  end

  add_index "subscriptions", ["subscribable_id"], :name => "index_subscriptions_on_subscribable_id"
  add_index "subscriptions", ["subscribable_type"], :name => "index_subscriptions_on_subscribable_type"
  add_index "subscriptions", ["user_id"], :name => "index_subscriptions_on_user_id"

  create_table "taggings", :force => true do |t|
    t.column "tag_id",        :integer
    t.column "tagger_id",     :integer
    t.column "taggable_id",   :integer
    t.column "taggable_type", :string
  end

  add_index "taggings", ["tag_id"], :name => "taggings_tag_id_index"
  add_index "taggings", ["taggable_id"], :name => "taggings_taggable_id_index"
  add_index "taggings", ["taggable_type"], :name => "taggings_taggable_type_index"
  add_index "taggings", ["tagger_id"], :name => "taggings_tagger_id_index"

  create_table "tags", :force => true do |t|
    t.column "name",            :string
    t.column "organization_id", :integer
  end

  add_index "tags", ["name"], :name => "tags_name_index"
  add_index "tags", ["organization_id"], :name => "tags_organization_id_index"

  create_table "user_options", :force => true do |t|
    t.column "user_id", :integer
    t.column "key",     :text
    t.column "value",   :text
  end

  add_index "user_options", ["user_id"], :name => "user_options_user_id_index"

  create_table "user_requests", :force => true do |t|
    t.column "user_id",      :string
    t.column "organization", :string
    t.column "username",     :string
    t.column "action",       :string
    t.column "created_at",   :datetime
    t.column "duration",     :float
    t.column "session_id",   :string
  end

  add_index "user_requests", ["user_id"], :name => "user_requests_user_id_index"

  create_table "users", :force => true do |t|
    t.column "person_id",                    :integer
    t.column "username",                     :string
    t.column "password",                     :string
    t.column "password_sha1",                :string
    t.column "admin",                        :boolean, :default => false, :null => false
    t.column "organization_id",              :integer
    t.column "documents_id",                 :integer
    t.column "full_name",                    :string
    t.column "identity_id",                  :integer
    t.column "guest",                        :boolean, :default => false, :null => false
    t.column "recovery_email",               :string,  :default => ""
    t.column "recovery_token",               :string,  :default => ""
    t.column "guest_rw",                     :boolean, :default => false, :null => false
    t.column "jajah_username",               :string
    t.column "jajah_password",               :string
    t.column "forward_address",              :string,  :default => ""
    t.column "facebook_session_key",         :string
    t.column "facebook_uid",                 :integer
    t.column "away_on",                      :boolean, :default => false
    t.column "away_expires_at",              :date
    t.column "away_message",                 :text
    t.column "last_away_replied_message_id", :integer, :default => 0,     :null => false
  end

  add_index "users", ["identity_id"], :name => "index_users_on_identity_id"
  add_index "users", ["documents_id"], :name => "users_documents_id_index"
  add_index "users", ["organization_id"], :name => "users_organization_id_index"
  add_index "users", ["person_id"], :name => "users_person_id_index"
  add_index "users", ["username"], :name => "users_username_index"

  create_table "websites", :force => true do |t|
    t.column "person_id",  :integer
    t.column "preferred",  :boolean, :default => false
    t.column "site_title", :string,  :default => ""
    t.column "site_url",   :string,  :default => ""
  end

  add_index "websites", ["person_id"], :name => "websites_person_id_index"

end
