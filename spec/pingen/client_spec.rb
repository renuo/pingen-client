RSpec.describe Pingen::Client, :vcr do
  let(:instance) { Pingen::Client.new }

  describe "#documents" do
    it "can fetch documents list" do
      response = instance.documents
      expect(response).to be_ok
      expect(response.json).to match(a_hash_including(items: array_including(a_hash_including(filename: "WelcomeLetter-it.pdf", address: "Renuo AG\nIndustriestrasse 44, 8304 Wallisellen\nSvizzera", country: "CH"))))
    end
  end
end
