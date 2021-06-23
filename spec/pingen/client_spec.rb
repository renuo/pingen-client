require "dotenv/load"

RSpec.describe Pingen::Client, :vcr do
  let(:instance) { Pingen::Client.new }

  describe "#documents" do
    subject(:response) { instance.documents }

    it "can fetch documents list" do
      expect(response).to be_ok
      expect(response.json).to match(a_hash_including(items: array_including(a_hash_including(filename: "WelcomeLetter-it.pdf", address: "Renuo AG\nIndustriestrasse 44, 8304 Wallisellen\nSvizzera", country: "CH"))))
    end
  end

  describe "#get" do
    subject(:response) { instance.get("804363203") }

    it "can fetch documents list" do
      expect(response).to be_ok
      expect(response.json).to match(a_hash_including(item: a_hash_including(filename: "WelcomeLetter-it.pdf", address: "Renuo AG\nIndustriestrasse 44, 8304 Wallisellen\nSvizzera", country: "CH")))
    end
  end

  describe "#upload" do
    subject(:response) { instance.upload(file) }

    let(:file) { File.join("spec/fixtures/test.pdf") }

    it "uploads the file" do
      expect(response).to be_ok
      expect(response.json).to match(a_hash_including(item: a_hash_including(filename: "test.pdf")))
    end
  end
end
