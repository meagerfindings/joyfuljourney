require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  describe "new_post_notification" do
    let(:mail) { NotificationMailer.new_post_notification }

    it "renders the headers" do
      expect(mail.subject).to eq("New post notification")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "new_milestone_notification" do
    let(:mail) { NotificationMailer.new_milestone_notification }

    it "renders the headers" do
      expect(mail.subject).to eq("New milestone notification")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "new_reaction_notification" do
    let(:mail) { NotificationMailer.new_reaction_notification }

    it "renders the headers" do
      expect(mail.subject).to eq("New reaction notification")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "user_tagged_notification" do
    let(:mail) { NotificationMailer.user_tagged_notification }

    it "renders the headers" do
      expect(mail.subject).to eq("User tagged notification")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "family_join_notification" do
    let(:mail) { NotificationMailer.family_join_notification }

    it "renders the headers" do
      expect(mail.subject).to eq("Family join notification")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
