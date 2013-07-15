require 'test_helper'

class TranscribableTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Transcribable
  end

  test "transcribable table is set" do
    assert_equal "filings", Transcribable.table
  end

  test "transcribable attrs are set" do
    h = {"buyer"=>:string, "amount"=>:integer, "notes"=>:text}
    assert_equal h, Transcribable.transcribable_attrs
  end

  test "skipped attr is set" do
    skipped = [:notes]
    assert_equal skipped, Filing.skipped_attrs
  end

  test "set verification level" do
    assert_equal 4, Filing.verification_threshhold
  end
end

class TranscribableAssignerTest < ActiveSupport::TestCase
  def setup
    @user = "40765bb0cfa90130c5fb442c03361f6e"
    @doc1 = Filing.create({:id => 1, :url => "https://www.documentcloud.org/documents/326844-fox-chicago-public-file", :verified => true})
    @doc2 = Filing.create({:id => 2, :url => "https://www.documentcloud.org/documents/326749-abc-chicago"})
    @doc3 = Filing.create({:id => 3, :url => "https://www.documentcloud.org/documents/326753-cbs-chicago-public-file"})

    @transcription1 = Transcription.create({:filing_id => 2, :user_id => @user})
  end

  def teardown
    Filing.delete_all
    Transcription.delete_all
  end

  test "should assign documents that aren't verified or transcribed by the user" do
    assigned = Filing.assign!(@user)
    assert_equal @doc3.id, assigned.id
  end
end

class TranscribableVerifierTest < ActiveSupport::TestCase
  def setup
    Filing.set_verification_threshhold(1)

    @user1 = "40765bb0cfa90130c5fb442c03361f6e"
    @user2 = "5aa499f0cfb30130c5fc442c03361f6e"

    @doc = Filing.create({:id => 1, :url => "https://www.documentcloud.org/documents/326749-abc-chicago"})

    @transcription1 = Transcription.create({:filing_id => 1, :user_id => @user1, :buyer => "Restore Our Future", :amount => 123.45})
    @transcription2 = Transcription.create({:filing_id => 1, :user_id => @user2, :buyer => "Restore our Future", :amount => 123.45})
  end

  def teardown
    Filing.delete_all
    Transcription.delete_all
  end

  test "should verify transcriptions" do
    f = Filing.find(1)
    f.verify!

    assert_equal true, f.verified
  end
end