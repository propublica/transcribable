ActiveRecord::Schema.define(version: 20130710175855) do

  create_table "filings", force: true do |t|
    t.string  "url"
    t.string  "buyer"
    t.integer "amount"
    t.boolean "verified"
    t.text    "notes"
  end

  create_table "transcriptions", force: true do |t|
    t.string  "buyer"
    t.integer "amount"
    t.integer "filing_id"
    t.string  "user_id"
    t.text    "notes"
  end

end
