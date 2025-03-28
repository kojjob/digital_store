require "test_helper"

class ContactMailerTest < ActionMailer::TestCase
  test "the truth" do
    assert true
  end

  test "contact mailer" do
    mail = ContactMailer.contact_mailer("test", "test", "test")
    assert_equal "test", mail.subject
    assert_equal [ "test" ], mail.to
    assert_equal [ "test" ], mail.from
    assert_match "test", mail.body.encoded
  end
  test "contact mailer with invalid email" do
    mail = ContactMailer.contact_mailer("test", "test", "test")
    assert_equal "test", mail.subject
    assert_equal [ "test" ], mail.to
    assert_equal [ "test" ], mail.from
    assert_match "test", mail.body.encoded
  end
end
