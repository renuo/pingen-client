require "dotenv/load"

RSpec.describe Pingen::Client, :vcr do
  let(:client) { Pingen::Client.new }
  let(:file) { File.join("spec/fixtures/test_valid.pdf") }

  describe "#documents" do
    let(:instance) { client.documents }

    describe "#list" do
      subject(:response) { instance.list }

      it "can fetch documents list" do
        expect(response).to be_ok
        expect(response.json).to match(a_hash_including(items: array_including(a_hash_including(filename: "WelcomeLetter-it.pdf", address: "Renuo AG\nIndustriestrasse 44, 8304 Wallisellen\nSvizzera", country: "CH"))))
      end
    end

    describe "#get" do
      subject(:response) { instance.get("804363203") }

      it "can fetch a specific document" do
        expect(response).to be_ok
        expect(response.json).to match(a_hash_including(item: a_hash_including(filename: "WelcomeLetter-it.pdf", address: "Renuo AG\nIndustriestrasse 44, 8304 Wallisellen\nSvizzera", country: "CH")))
      end
    end

    describe "#upload" do
      subject(:response) { instance.upload(file) }

      it "uploads the file" do
        expect(response).to be_ok
        expect(response.json).to match(a_hash_including(item: a_hash_including(filename: "test.pdf")))
      end

      context "when also sending the file" do
        subject(:response) { instance.upload(file, send: true) }

        it "uploads file and schedules the sending" do
          expect(response).to be_ok
          expect(response.json).to match(a_hash_including(item: a_hash_including(status: 1, requirement_failure: 0),
                                                          send: [a_hash_including(:document_id, :send_id)]))
        end
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

    describe "#send" do
      subject(:response) { instance.send(id) }

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

  describe "#sends" do
    let(:instance) { client.sends }

    describe "#list" do
      subject(:response) { instance.list }

      it "returns a successful response" do
        expect(response).to be_ok
        expect(response.json).to match(a_hash_including(:items, error: false))
      end
    end

    describe "#get" do
      subject(:response) { instance.get("11659418") }

      it "can fetch a specific send" do
        expect(response).to be_ok
        expect(response.json).to match(a_hash_including(:item, error: false))
      end
    end

    describe "#cancel" do
      let(:send_id) { client.documents.upload(file, send: true).json.dig(:send, 0, :send_id) }
      subject(:response) { instance.cancel(send_id) }

      it "returns a successful response" do
        expect(response).to be_ok
        expect(response.json).to eq({error: false})
      end
    end

    describe "#track" do
      subject(:response) { instance.track("51258965") }

      it "returns a list of trackings" do
        expect(response).to be_ok
        expect(response.json).to match(error: false, item: a_hash_including(:tracking_id, :product, :status, :events))
      end
    end
  end
end
