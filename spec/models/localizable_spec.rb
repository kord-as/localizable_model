# encoding: utf-8

require "rails_helper"

describe "Localizable", type: :model do
  describe ".localized" do
    let!(:norwegian_page) { Page.create(name: "Test", locale: "nb") }
    let!(:english_page) { Page.create(name: "Test", locale: "en") }
    subject { Page.localized("nb") }
    it { is_expected.to include(norwegian_page) }
    it { is_expected.not_to include(english_page) }
  end

  describe ".locales" do
    let(:localizable) do
      Page.create(
        body: { "en" => "My test page", "nb" => "Testside" },
        locale: "en"
      )
    end
    subject { localizable.locales }
    it { is_expected.to match(%w(en nb)) }
  end

  describe "setting multiple locales" do
    let(:page) do
      Page.create(
        body: { "en" => "My test page", "nb" => "Testside" },
        locale: "en"
      )
    end

    it "should respond with the locale specific string" do
      expect(page.body?).to eq(true)
      expect(page.body.to_s).to eq("My test page")
      expect(page.localize("nb").body.to_s).to eq("Testside")
    end

    it "should remove the unnecessary locales" do
      expect(page.locales).to match(%w(en nb))
      page.update(body: "")
      page.reload
      expect(page.locales).to match(["nb"])
    end
  end

  it "should return a blank Localization for uninitialized columns" do
    page = Page.new
    expect(page.body?).to eq(false)
    expect(page.body).to be_a(String)
  end

  describe "with a body" do
    let(:page) { Page.create(body: "My test page", locale: "en") }

    it "responds to body?" do
      expect(page.body?).to eq(true)
      page.body = nil
      expect(page.body?).to eq(false)
    end

    it "body should be a localization" do
      expect(page.body).to be_kind_of(String)
      expect(page.body.to_s).to eq("My test page")
    end

    it "should be changed when saved" do
      page.update(body: "Hi")
      page.reload
      expect(page.body.to_s).to eq("Hi")
    end

    it "should remove the localization when nilified" do
      page.update(body: nil)
      expect(page.valid?).to eq(true)
      page.reload
      expect(page.body?).to eq(false)
    end
  end
end