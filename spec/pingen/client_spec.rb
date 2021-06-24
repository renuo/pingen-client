require "dotenv/load"

RSpec.describe Pingen::Client, :vcr do
  let(:instance) { Pingen::Client.new }

  describe "#list" do
    subject(:response) { instance.list }

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

  describe "#pdf" do
    subject(:response) { instance.pdf("335344089") }

    it "returns the PDF" do
      expect(response).to be_ok
    end
  end

  describe "#delete" do
    subject(:response) { instance.delete("335344089") }

    it "deletes the document" do
      expect(response).to be_ok
      expect(response.json).to match(error: false)
    end
  end

  describe "#schedule_send" do
    subject(:response) { instance.schedule_send(id) }

    let(:id) { "804363203" }

    it "sends the document" do
      expect(response).to be_ok
      expect(response.json).to match(error: false, id: 84376190)
    end

    context "when error occurs" do
      let(:id) { "303870085" }

      it "returns error" do
        expect(response).not_to be_ok
        expect(response.code).to eq 400
        expect(response.json).to match(error: true, errorcode: 2016, errormessage: "No valid country could be detected")
      end
    end
  end
end
